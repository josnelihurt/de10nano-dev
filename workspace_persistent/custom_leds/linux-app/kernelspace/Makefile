
KDIR ?= /mnt/c/code/de10nano/examples/linux_socfpga
HOST = 192.168.0.11

default:
	$(MAKE) -C $(KDIR) ARCH=arm M=$(CURDIR)

clean:
	$(MAKE) -C $(KDIR) ARCH=arm M=$(CURDIR) clean

help:
	$(MAKE) -C $(KDIR) ARCH=arm M=$(CURDIR) help


install:custom_leds.ko
	scp custom_leds.ko root@${HOST}:/tmp