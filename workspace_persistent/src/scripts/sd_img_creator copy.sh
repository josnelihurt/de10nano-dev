#!/bin/bash
#https://blog.aignacio.com/fpga-linux-co-design-with-cyclone-v-part-2-3/
#warning for a reason that idk I was not able to make it works on docker
echo "create img"
dd if=/dev/zero of=sdcard.img bs=512M count=1
echo "mount loop 7"
losetup -d /dev/loop5
losetup /dev/loop5 sdcard.img
echo "call fdisk"

#The steps seems to be ok 
cat << EOF  | fdisk /dev/loop5
n
p
3

4095
t
a2
n
p
1

+32M
t
1
b
n
p
2


t
2
83
p
w
EOF
partprobe /dev/loop5
dd if=/home/builder/output/preloader-mkpimage.bin of=/dev/loop5p3 bs=64k
mkfs.vfat -F 32 /dev/loop5p1
mkfs.ext3 /dev/loop5p2
mkdir -p /tmp/mnt/sdimg/p1
mount /dev/loop5p1 /tmp/mnt/sdimg/p1
mkdir -p /tmp/mnt/sdimg/p2
mount /dev/loop5p2 /tmp/mnt/sdimg/p2
cp 	/home/builder/output/u-boot.img \
	/home/builder/output/custom_leds/u-boot.scr \
	/home/builder/output/custom_leds/soc_system.dtb \
	/home/builder/output/custom_leds/soc_system.rbf \
	/home/builder/output/zImage \
	/tmp/mnt/sdimg/p1/
tar -xvf /home/builder/output/rootfs.tar -C /tmp/mnt/sdimg/p2/
cp -r /home/builder/output/custom_leds/custom_leds.ko \
	/home/builder/output/custom_leds/devmem_demo \
	/home/builder/output/custom_leds/test_custom_leds.ko.sh \
	/tmp/mnt/sdimg/p2/root/
sync
umount /tmp/mnt/sdimg/p2
umount /tmp/mnt/sdimg/p1
losetup -d /dev/loop5
sync