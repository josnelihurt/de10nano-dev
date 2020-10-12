FROM debian:stretch
LABEL author="josnelihurt rodriguez <josnelihurt@gmail.com>"
ENV TERM dumb

# apt config:  silence warnings and set defaults
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt update
RUN apt upgrade -y

# Create a non-root user for builds
RUN adduser --disabled-password --gecos '' builder && \
    usermod builder -aG staff

# turn off recommends on container OS
# install required dependencies

RUN echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > \
    /etc/apt/apt.conf.d/01norecommend
RUN apt-get update
RUN apt-get -y install ca-certificates 
RUN apt-get -y install git 
RUN apt-get -y install wget

# Individual downloads Quartus, ModelSim and Device Support
USER builder
WORKDIR /home/builder
RUN wget http://download.altera.com/akdlm/software/acdsinst/17.1std/590/ib_installers/QuartusLiteSetup-17.1.0.590-linux.run 
RUN wget http://download.altera.com/akdlm/software/acdsinst/17.1std/590/ib_installers/ModelSimSetup-17.1.0.590-linux.run 
RUN wget http://download.altera.com/akdlm/software/acdsinst/17.1std/590/ib_installers/cyclonev-17.1.0.590.qdz
# Integrated package with device support
RUN wget http://download.altera.com/akdlm/software/acdsinst/17.1std/590/ib_tar/Quartus-lite-17.1.0.590-linux.tar 
# SoC EDS, needed for software support of Cyclone V HPS
RUN wget http://download.altera.com/akdlm/software/acdsinst/17.1std/590/ib_installers/SoCEDSSetup-17.1.0.590-linux.run

# Download repositories
RUN git clone https://github.com/altera-opensource/linux-socfpga.git 
RUN git clone git://git.buildroot.net/buildroot

#build root RUN git checkout 2018.05.1 
#kernel -> git checkout rel_socfpga-4.9.78-ltsi_18.07.02_pr #Check your repository for the latest, in my case I went with this one

# Download cross compile tools
#gcc 6.3 this is for uboot 'cause it seems to fail with newer versions
RUN wget https://releases.linaro.org/components/toolchain/binaries/latest-6/arm-linux-gnueabihf/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz
#gcc 7.1 this is for the rest
RUN wget https://releases.linaro.org/components/toolchain/binaries/7.1-2017.05/arm-linux-gnueabihf/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz

# Download CD-ROOM tools from Terasic for DE10-nano
RUN wget http://download.terasic.com/downloads/cd-rom/de10-nano/DE10-Nano_v.1.3.8_HWrevC_SystemCD.zip
RUN wget http://download.terasic.com/downloads/cd-rom/de10-nano/AngstromImage/de10-nano-image-Angstrom-v2016.12.socfpga-sdimg.2017.03.31.tgz

#All downloads done, now starting the installation process, this is the list of files
RUN pwd
RUN ls -lah

USER root
RUN apt-get -y install libfontconfig1 
RUN apt-get -y install libglib2.0-0 
RUN apt-get -y install libsm6 
RUN apt-get -y install libxrender1 
RUN apt-get -y install locales 
RUN apt-get -y install make 
RUN apt-get -y install xauth 
RUN apt-get -y install xvfb 
RUN apt-get -y install pkg-config 
RUN apt-get -y install libprotobuf-dev 
RUN apt-get -y install protobuf-compiler 
RUN apt-get -y install python-protobuf 
RUN apt-get -y install python3-pip 
RUN apt-get -y install libpng16-16 
RUN apt-get -y install udisks2
RUN apt-get -y install nano
RUN apt-get -y install vim
RUN apt-get -y install tmux
RUN apt-get -y install file
RUN apt-get -y install cpio
RUN apt-get -y install rsync
RUN apt-get -y install build-essential 
RUN apt-get -y install libncurses5-dev
RUN apt-get -y install bc
RUN apt-get -y install xz-utils 
RUN apt-get -y install zip unzip
RUN pip3 install intelhex

# Set the locale, Quartus expects en_US.UTF-8
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Allow builder to sudo without password
RUN echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER builder

# Prepare permissions to install components
WORKDIR /home/builder
RUN chmod +x ModelSimSetup-17.1.0.590-linux.run
RUN chmod +x QuartusLiteSetup-17.1.0.590-linux.run
RUN chmod +x SoCEDSSetup-17.1.0.590-linux.run

# Install components 
RUN ./QuartusLiteSetup-17.1.0.590-linux.run --mode unattended --accept_eula 1 --disable-components quartus_help
RUN ./SoCEDSSetup-17.1.0.590-linux.run --mode unattended --accept_eula 1 \
    --installdir /home/builder/intelFPGA_lite/17.1/
ENV PATH $PATH:/home/builder/intelFPGA_lite/17.1/quartus/bin|

RUN ls -lah
RUN tar -xvf gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz
RUN tar -xvf gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz

#export CROSS_COMPILE=$PWD/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
#export CROSS_COMPILE=$PWD/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-


# Clean-up, you can extract this files from the container if you need it 
RUN mkdir downloads
RUN mv gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz downloads
RUN mv gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz downloads
RUN mv ModelSimSetup-17.1.0.590-linux.run downloads
RUN mv QuartusLiteSetup-17.1.0.590-linux.run downloads
RUN mv SoCEDSSetup-17.1.0.590-linux.run downloads

RUN unzip DE10-Nano_v.1.3.8_HWrevC_SystemCD.zip -d DE10-Nano_SystemCD 
RUN mv DE10-Nano_v.1.3.8_HWrevC_SystemCD.zip downloads

RUN echo "Installation completed, this is the list of files"
RUN ls -lah

# Build the kernel
USER root
ENV TERM=xterm-color
USER builder

WORKDIR /home/builder/linux-socfpga
ENV CROSS_COMPILE=/home/builder/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
RUN git checkout rel_socfpga-4.9.78-ltsi_18.07.02_pr

#RUN make ARCH=arm socfpga_defconfig
#COPY linux.config .config
RUN make ARCH=arm socfpga_defconfig
RUN make ARCH=arm LOCALVERSION= zImage -j$(nproc)

# Build rootfs
WORKDIR /home/builder/buildroot
RUN git checkout 2018.05.1 
COPY buildroot.config .config
WORKDIR /home/builder
RUN make -C buildroot ARCH=ARM oldconfig
RUN make -C buildroot ARCH=ARM \
        -j$(nproc) \ 
        BR2_TOOLCHAIN_EXTERNAL_PATH=/home/builder/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf all

# Build uboot

# Set output files
RUN mkdir output
RUN ln -s linux_socfpga/arch/arm/boot/zImage /home/builder/output/zImage
RUN ln -s buildroot/output/image/rootfs.tar /home/builder/output/rootfs.tar

USER root
RUN usermod -aG sudo builder
USER builder

ENTRYPOINT ["/bin/bash"]