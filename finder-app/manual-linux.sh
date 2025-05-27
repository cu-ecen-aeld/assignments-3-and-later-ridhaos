#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-linux-gnu-
CROSS_SYSROOT=/usr/aarch64-linux-gnu/

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    # Set Target
    export ARCH=${ARCH}
    export CROSS_COMPILE=${CROSS_COMPILE}

    # Set Default configuration
    make defconfig
    # Make allnoconfig for minimal configuration
    #make allnoconfig
    set -u

    NPROC="$(nproc)"
    echo "Building linux with ${NPROC} process"

    make -j${NPROC}

fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}/


echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
echo "Make root Fs directories"
mkdir -p rootfs/{bin,sbin,etc,proc,sys,usr/{bin,sbin},lib,lib64,dev,tmp,home}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone https://git.busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make distclean
    make defconfig
else
    cd busybox
fi

export ARCH
export CROSS_COMPILE


# TODO: Make and install busybox
make -j$(nproc)
make CONFIG_PREFIX=${OUTDIR}/rootfs install
cd ${OUTDIR}/rootfs

echo "We are now in $(pwd)"
echo "Library dependencies"

${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "NEEDED"
# TODO: Add library dependencies to rootfs

copy_lib() {
    libname="$1"
}

interp=$(${CROSS_COMPILE}readelf -l bin/busybox | grep "program interpreter" | awk -F: '{print $2}' | tr -d ' []')
interp_name=$(basename "$interp")
interpath=$(find $CROSS_SYSROOT -name "$interp_name" 2>/dev/null | head -n 1)
if [ -z "$interpath" ]; then
    echo "Error Missing: $interp_name"
else
    echo "Copying $interp_name from $interpath"
    cp "$interpath" "${OUTDIR}/rootfs/lib/"
fi

libs=$(${CROSS_COMPILE}readelf -d bin/busybox | grep "Shared library" | awk -F'[][]' '{print $2}')
for lib in $libs; do

    libpath=$(find $CROSS_SYSROOT -name "$lib" 2>/dev/null | head -n 1)
    if [ -z "$libpath" ]; then
        echo "Error Missing: $lib"
    else
        echo "Copying $lib from $libpath"
        cp "$libpath" "${OUTDIR}/rootfs/lib/"
    fi
done

# TODO: Make device nodes
sudo mknod -m 622 ${OUTDIR}/rootfs/dev/console c 5 1
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3

# TODO: Clean and build the writer utility
echo "Clean and build the writer utility"
echo "Return to main Rep ${FINDER_APP_DIR}/finder-app"
cd ${FINDER_APP_DIR}
make clean
make CROSS_COMPILE=${CROSS_COMPILE}

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp ${FINDER_APP_DIR}/writer ${OUTDIR}/rootfs/home/
cp ${FINDER_APP_DIR}/finder.sh ${OUTDIR}/rootfs/home/
cp ${FINDER_APP_DIR}/finder-test.sh ${OUTDIR}/rootfs/home/
cp -rL ${FINDER_APP_DIR}/conf ${OUTDIR}/rootfs/home/
cp ${FINDER_APP_DIR}/autorun-qemu.sh ${OUTDIR}/rootfs/home/

sed -i 's|\.\./conf|conf|' ${OUTDIR}/rootfs/home/finder-test.sh

# TODO: Chown the root directory
sudo chown -R root:root ${OUTDIR}/rootfs/


# TODO: Create initramfs.cpio.gz
cd ${OUTDIR}/rootfs/


find . | cpio -H newc -ov --owner root:root | gzip -9 > ../initramfs.cpio.gz