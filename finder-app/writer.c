/*
Write a shell script finder-app/writer.sh as described below:

    1)Accepts the following arguments: the first argument is a 
    full path to a file (including filename) on the filesystem, 
    referred to below as writefile; the second argument is a text 
    string which will be written within this file, referred to below as writestr

    2)Exits with value 1 error and print statements if any of the arguments above were not specified

    3)Creates a new file with name and path writefile with content writestr, 
    overwriting any existing file and creating the path if it doesn’t exist. 
    Exits with value 1 and error print statement if the file could not be created.
*/
#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>
#include <errno.h>

#define LOG_ENABLE_PRINT 0

#if LOG_ENABLE_PRINT
#define PRINTF(...) printf(__VA_ARGS__)
#else
#define PRINTF(...) (void)0
#endif

int main (int argc, char **argv)
{
    openlog("writer.c", 0, LOG_USER);
    if (argc != 3)
    {
        printf("Arguments Invalid 2 need to run this script\n");
        syslog(LOG_ERR, "Invalid number of arguments must be 2 and was %d", argc);
        closelog();
        return 1;
    }
    

    FILE *fp = fopen(argv[1], "w");
    
    PRINTF("Arguments : %s , %s\n", argv[1], argv[2]);
    if(fp)
    {
        PRINTF("File Readed now to write");

        errno = 0;
        
        fputs(argv[2], fp);

        if(errno != 0)
        {
            syslog(LOG_ERR, "Error during Write ERRNO Code =  %d", errno);
        }else
        {
            syslog(LOG_DEBUG, "Writing %s to %s", argv[2], argv[1]);
        }
        fclose(fp);
        
    }else{
        PRINTF("Null Pointer error to read error, errno %d\n", errno);
        syslog(LOG_ERR, "Error File %s not exist", argv[1]);
    }

    closelog();
}