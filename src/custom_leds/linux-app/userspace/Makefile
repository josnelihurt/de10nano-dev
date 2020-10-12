TARGET = devmem_demo
HOST = 192.168.0.8

#docker run --rm dockcross/linux-armv7 > /usr/local/sbin/dockcross-linux-armv7
# chmod +x /usr/local/bin/dockcross-linux-arm7
# /usr/local/bin/dockcross-linux-arm7 make

CFLAGS = -static -g -Wall -std=gnu99
LDFLAGS = -g -Wall
CC = $(CROSS_COMPILE)gcc
ARCH = arm

build: $(TARGET)
$(TARGET): main.o
	$(CC) $(LDFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

install:$(TARGET)
	scp $(TARGET) root@${HOST}:/tmp

shell:$(TARGET)
	ssh root@${HOST} 

run:$(TARGET) install
	ssh root@${HOST} '/tmp/${TARGET}' 

.PHONY: clean
clean:
	rm -f $(TARGET) *.a *.o *.~