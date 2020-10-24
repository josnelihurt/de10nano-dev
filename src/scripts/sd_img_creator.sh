#!/bin/bash
#https://blog.aignacio.com/fpga-linux-co-design-with-cyclone-v-part-2-3/
echo "create img"
MNT=/tmp
DEST_DIR=/output

if [ -f "$DEST_DIR/sdcard.img" ]; then
    echo "nothing to do delete sdcard.img file if you wanna run it again"
    exit 0
fi
echo "about to run the sd-creator"
echo "what is in /home/builder/output"
ls /home/builder/output
echo "what is in /home/builder/output/custom_leds"
ls /home/builder/output/custom_leds
rm de10_nano_linux_console.img
rm de10_nano_linux_console.txt
unzip de10_nano_linux_console.zip
mv de10_nano_linux_console.img sdcard.img
sync
ls /dev/loop*
LOOPDEV=/dev/loop7
LOOPDEVP1=/dev/loop7p1
LOOPDEVP2=/dev/loop7p2
LOOPDEVP3=/dev/loop7p3
losetup -d $LOOPDEV
losetup $LOOPDEV sdcard.img
sync
partprobe $LOOPDEV
umount $LOOPDEVP1
umount $LOOPDEVP2
umount $LOOPDEVP3
partprobe $LOOPDEV
sync

dd if=/home/builder/output/preloader-mkpimage.bin of=$LOOPDEVP3 bs=64k
sync
rm -rf $MNT
mkdir -p $MNT/sdimg/p1
mkdir -p $MNT/sdimg/p2
sync
mount $LOOPDEVP1 $MNT/sdimg/p1
mount $LOOPDEVP2 $MNT/sdimg/p2
sync
rm -rf $MNT/sdimg/p1/*
rm -rf $MNT/sdimg/p2/*

cp /home/builder/output/custom_leds/u-boot.img $MNT/sdimg/p1/;
cp /home/builder/output/u-boot.scr \
 /home/builder/output/zImage \
 /home/builder/output/custom_leds/soc_system.dtb \
 /home/builder/output/custom_leds/soc_system.rbf \
 $MNT/sdimg/p1/ >> /dev/null
tar -xvf /home/builder/output/rootfs.tar -C $MNT/sdimg/p2/ >>/dev/null
cp /home/builder/output/custom_leds/custom_leds.ko \
 /home/builder/output/custom_leds/devmem_demo \
 /home/builder/output/custom_leds/test_custom_leds.ko.sh \
 $MNT/sdimg/p2/root/
sync

ls -lah $MNT/sdimg/p1/
umount $MNT/sdimg/p2
umount $MNT/sdimg/p1
losetup -d $LOOPDEV

mv sdcard.img $DEST_DIR/sdcard.img
sync
