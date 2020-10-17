#!/bin/bash

DEST_DIR=/downloads
echo "starting using DEST_DIR $DEST_DIR"

# if [ ! -f "$DEST_DIR/buildroot.tar" ]; then
#     cd /tmp
#     git clone git://git.buildroot.net/buildroot
#     tar -cvf buildroot.tar buildroot
#     cp buildroot.tar $DEST_DIR
#     rm -rf /tmp/*
#     cd $DEST_DIR
#     #wget "https://codeload.github.com/buildroot/buildroot/zip/master" -O buildroot.zip
# fi

# if [ ! -f "$DEST_DIR/linux-socfpga.tar" ]; then
#     cd /tmp
#     git clone https://github.com/altera-opensource/linux-socfpga.git
#     tar -cvf linux-socfpga.tar linux-socfpga
#     cp linux-socfpga.tar $DEST_DIR
#     rm -rf /tmp/*
#     cd $DEST_DIR
    
#     #wget "https://codeload.github.com/altera-opensource/linux-socfpga/zip/socfpga-5.4.54-lts" -O linux-socfpga.zip
# fi

if [ ! -f "$DEST_DIR/nomachine_6.12.3_8_i386.deb" ]; then
    wget "https://download.nomachine.com/download/6.12/Linux/nomachine_6.12.3_8_i386.deb"
fi

# Download CD-ROOM tools from Terasic for DE10-nano
if [ ! -f "$DEST_DIR/DE10-Nano_v.1.3.8_HWrevC_SystemCD.zip" ]; then
    wget "http://download.terasic.com/downloads/cd-rom/de10-nano/DE10-Nano_v.1.3.8_HWrevC_SystemCD.zip"
fi

if [ ! -f "$DEST_DIR/de10_nano_linux_console.zip" ]; then
    wget "http://download.terasic.com/downloads/cd-rom/de10-nano/linux_BSP/de10_nano_linux_console.zip"
fi

# Download cross compile tools
#gcc 6.3 this is for uboot 'cause it seems to fail with newer versions

if [ ! -f "$DEST_DIR/gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf.tar.xz" ]; then
    wget "https://releases.linaro.org/components/toolchain/binaries/6.3-2017.02/arm-linux-gnueabihf/gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf.tar.xz"
fi

if [ ! -f "$DEST_DIR/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz" ]; then
    wget "https://releases.linaro.org/components/toolchain/binaries/latest-6/arm-linux-gnueabihf/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz"
fi

#gcc 7.1 this is for the rest
if [ ! -f "$DEST_DIR/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz" ]; then
    wget "https://releases.linaro.org/components/toolchain/binaries/7.1-2017.05/arm-linux-gnueabihf/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz"
fi

# Download Quartus
if [ ! -f "$DEST_DIR/QuartusLiteSetup-17.1.0.590-linux.run" ]; then
    wget "http://download.altera.com/akdlm/software/acdsinst/17.1std/590/ib_installers/QuartusLiteSetup-17.1.0.590-linux.run"
fi
if [ ! -f "$DEST_DIR/ModelSimSetup-17.1.0.590-linux.run" ]; then
    wget "http://download.altera.com/akdlm/software/acdsinst/17.1std/590/ib_installers/ModelSimSetup-17.1.0.590-linux.run"
fi
if [ ! -f "$DEST_DIR/cyclonev-17.1.0.590.qdz" ]; then
    wget "http://download.altera.com/akdlm/software/acdsinst/17.1std/590/ib_installers/cyclonev-17.1.0.590.qdz"
fi
if [ ! -f "$DEST_DIR/Quartus-lite-17.1.0.590-linux.tar" ]; then
    wget "http://download.altera.com/akdlm/software/acdsinst/17.1std/590/ib_tar/Quartus-lite-17.1.0.590-linux.tar"
fi
if [ ! -f "$DEST_DIR/SoCEDSSetup-17.1.0.590-linux.run" ]; then
    wget "http://download.altera.com/akdlm/software/acdsinst/17.1std/590/ib_installers/SoCEDSSetup-17.1.0.590-linux.run"
fi

echo "done"