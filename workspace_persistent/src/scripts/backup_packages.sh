#!/bin/bash
echo "start"

SRC_DIR=/home/builder/downloads
DEST_DIR=/backup

if [ ! -f "$DEST_DIR/nomachine_6.12.3_8_i386.deb" ]; then
    echo "backup nomachine_6.12.3_8_i386.deb"
    cp $SRC_DIR/nomachine_6.12.3_8_i386.deb $DEST_DIR/
fi

if [ ! -f "$DEST_DIR/DE10-Nano_v.1.3.8_HWrevC_SystemCD.zip" ]; then
    echo "DE10-Nano_v.1.3.8_HWrevC_SystemCD.zip"
    cp $SRC_DIR/de10-nano/DE10-Nano_v.1.3.8_HWrevC_SystemCD.zip $DEST_DIR/
fi

# Download CD-ROOM tools from Terasic for DE10-nano
if [ ! -f "$DEST_DIR/de10-nano-image-Angstrom-v2016.12.socfpga-sdimg.2017.03.31.tgz" ]; then
    echo "de10-nano-image-Angstrom-v2016.12.socfpga-sdimg.2017.03.31.tgz"
   cp $SRC_DIR/de10-nano-image-Angstrom-v2016.12.socfpga-sdimg.2017.03.31.tgz $DEST_DIR/
fi

# Download cross compile tools
#gcc 6.3 this is for uboot 'cause it seems to fail with newer versions
if [ ! -f "$DEST_DIR/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz" ]; then
    echo "gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz"
    cp $SRC_DIR/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz $DEST_DIR/
fi

#gcc 7.1 this is for the rest
if [ ! -f "$DEST_DIR/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz" ]; then
    echo "gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz"
    cp $SRC_DIR/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz $DEST_DIR/
fi

# Download Quartus
if [ ! -f "$DEST_DIR/QuartusLiteSetup-17.1.0.590-linux.run" ]; then
    echo "QuartusLiteSetup-17.1.0.590-linux.run"
    cp $SRC_DIR/QuartusLiteSetup-17.1.0.590-linux.run $DEST_DIR/
fi
if [ ! -f "$DEST_DIR/ModelSimSetup-17.1.0.590-linux.run" ]; then
    echo "ModelSimSetup-17.1.0.590-linux.run"
    cp $SRC_DIR/ModelSimSetup-17.1.0.590-linux.run $DEST_DIR/
fi
if [ ! -f "$DEST_DIR/cyclonev-17.1.0.590.qdz" ]; then
    echo "cyclonev-17.1.0.590.qdz"
    cp $SRC_DIR/cyclonev-17.1.0.590.qdz $DEST_DIR/
fi
if [ ! -f "$DEST_DIR/Quartus-lite-17.1.0.590-linux.tar" ]; then
    echo "Quartus-lite-17.1.0.590-linux.tar"
    cp $SRC_DIR/Quartus-lite-17.1.0.590-linux.tar $DEST_DIR/
fi
if [ ! -f "$DEST_DIR/SoCEDSSetup-17.1.0.590-linux.run" ]; then
    echo "SoCEDSSetup-17.1.0.590-linux.run"
    cp $SRC_DIR/SoCEDSSetup-17.1.0.590-linux.run $DEST_DIR/
fi

echo "done"