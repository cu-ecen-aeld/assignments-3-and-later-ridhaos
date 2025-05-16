# Default compiler and flags
CC := $(CROSS_COMPILE)gcc
CFLAGS := -Wall -g -Werror

# Target bin and source
TARGET := writer
SRCS := writer.o
OBJS := $(SRCS:.c=.o)

# Default target (build the binary)
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

# Rule to compile .c into .o
%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

#clean target
clean:
	rm -f $(TARGET) *.o

.PHONY: clean