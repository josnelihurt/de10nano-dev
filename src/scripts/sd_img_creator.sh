#!/bin/bash
#https://blog.aignacio.com/fpga-linux-co-design-with-cyclone-v-part-2-3/
echo "create img"
rm de10_nano_linux_console.img
rm sdcard.img
rm de10_nano_linux_console.txt
unzip de10_nano_linux_console.zip
mv de10_nano_linux_console.img sdcard.img

losetup -d /dev/loop5
losetup /dev/loop5 sdcard.img
partprobe /dev/loop5
dd if=/home/builder/output/preloader-mkpimage.bin of=/dev/loop5p3 bs=64k

rm -rf /tmp/mnt/
mkdir -p /tmp/mnt/sdimg/p1
mkdir -p /tmp/mnt/sdimg/p2

mount /dev/loop5p1 /tmp/mnt/sdimg/p1
mount /dev/loop5p2 /tmp/mnt/sdimg/p2
rm -rf /tmp/mnt/sdimg/p1/*
rm -rf /tmp/mnt/sdimg/p2/*

cp /home/builder/output/u-boot.img \
 /home/builder/output/custom_leds/u-boot.scr \
 /home/builder/output/custom_leds/soc_system.dtb \
 /home/builder/output/custom_leds/soc_system.rbf \
 /home/builder/output/zImage \
 /tmp/mnt/sdimg/p1/
tar -xvf /home/builder/output/rootfs.tar -C /tmp/mnt/sdimg/p2/
cp /home/builder/output/custom_leds/custom_leds.ko \
 /home/builder/output/custom_leds/devmem_demo \
 /home/builder/output/custom_leds/test_custom_leds.ko.sh \
 /tmp/mnt/sdimg/p2/root/
sync
ls -lah /tmp/mnt/sdimg/p1/
umount /tmp/mnt/sdimg/p2
umount /tmp/mnt/sdimg/p1
losetup -d /dev/loop5
sync
