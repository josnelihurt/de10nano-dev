####################################################################################################################################
FROM nginx as downloader
####################################################################################################################################
FROM debian:stretch as debian-nxserver
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
RUN apt-get update; \
    apt-get -y install libfontconfig1 ca-certificates  \
    git wget libglib2.0-0 libsm6 libxrender1     \
    locales make xauth xvfb pkg-config libprotobuf-dev     \
    protobuf-compiler python-protobuf python3-pip     \
    libpng16-16 udisks2 nano vim tmux file cpio    \
    rsync build-essential libncurses5-dev bc  \
    xz-utils zip unzip sudo locales \
    libtcmalloc-minimal4 libglib2.0-0 apt-utils \
    xfce4 caja fcitx-mozc dbus-x11 x11-xserver-utils   \
    xfce4-terminal  \
    ; \  
    pip3 install intelhex
# Install i386 dependencies
RUN sudo dpkg --add-architecture i386; \
    sudo apt-get update; \
    sudo apt-get install -y \
    libxft2:i386 libxext6:i386 libncurses5:i386 \
    libc6:i386 libstdc++6:i386 unixodbc-dev \
    lib32ncurses5-dev libzmq3-dev gtk2-engines-pixbuf:i386 \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install nxserver
WORKDIR /tmp
RUN apt-get clean && apt-get update && \
    apt-get update -y && \
    apt-get install -y xterm libgconf2-4 iputils-ping libxss1 wget xdg-utils \
    libpango1.0-0 fonts-liberation xfce4-goodies htop gnome-icon-theme    
ADD default-config-files/nxserver.sh /nxserver.sh
ADD ./downloader/downloads/nomachine_6.12.3_8_i386.deb .
RUN dpkg -i nomachine_6.12.3_8_i386.deb && \
    sudo sed -i "s|#EnableClipboard both|EnableClipboard both |g" /usr/NX/etc/server.cfg; \
    rm nomachine_6.12.3_8_i386.deb

####################################################################################################################################
FROM nxserver-debian as builder

# Allow builder to sudo without password
RUN echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN usermod -aG sudo builder

USER builder
ENV TERM=xterm-color

WORKDIR /home/builder/downloads
ADD default-config-files/.profile /home/builder/.profile
ADD default-config-files/.config /home/builder/.config
RUN sudo chown -R builder /home/builder/.profile; sudo chown -R builder /home/builder/.config; \\
    mkdir /home/builder/.icons; \
    cp -r /usr/share/icons/* /home/builder/.icons; \
    sudo chown -R builder /home/builder/.icons

COPY --chown=builder \
    ./downloader/downloads/ModelSimSetup-17.1.0.590-linux.run \
    ./downloader/downloads/QuartusLiteSetup-17.1.0.590-linux.run \
    ./downloader/downloads/Quartus-lite-17.1.0.590-linux.tar \
    ./downloader/downloads/SoCEDSSetup-17.1.0.590-linux.run \
    ./downloader/downloads/cyclonev-17.1.0.590.qdz \
    ./downloader/downloads/DE10-Nano_v.1.3.8_HWrevC_SystemCD.zip \
    ./downloader/downloads/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz \
    ./downloader/downloads/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz \
    ./downloader/downloads/linux-socfpga.zip \
    ./downloader/downloads/buildroot.zip \
    ./

# Install components 
RUN chmod +x ModelSimSetup-17.1.0.590-linux.run \
    QuartusLiteSetup-17.1.0.590-linux.run \
    SoCEDSSetup-17.1.0.590-linux.run; \
    ./QuartusLiteSetup-17.1.0.590-linux.run --mode unattended --accept_eula 1 \
    --disable-components quartus_help; \
    rm QuartusLiteSetup-17.1.0.590-linux.run; \
    ./SoCEDSSetup-17.1.0.590-linux.run --mode unattended --accept_eula 1 \
    --installdir /home/builder/intelFPGA_lite/17.1/; \
    rm SoCEDSSetup-17.1.0.590-linux.run
# export quartus path
ENV PATH $PATH:/home/builder/intelFPGA_lite/17.1/quartus/bin

WORKDIR /home/builder
#extract cross tools and git repositories
RUN tar -xvf downloads/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz; \
    rm downloads/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz; \
    tar -xvf downloads/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz; \
    rm downloads/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz; \
    unzip downloads/linux-socfpga.zip -d /home/builder/linux-socfpga; \
    rm downloads/linux-socfpga.zip ; \
    unzip downloads/buildroot.zip -d /home/builder/buildroot; \
    rm downloads/buildroot.zip

#export CROSS_COMPILE=$PWD/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
#export CROSS_COMPILE=$PWD/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

# Build and install libpng used by quartus
WORKDIR /tmp
RUN wget https://netactuate.dl.sourceforge.net/project/libpng/libpng12/1.2.59/libpng-1.2.59.tar.gz; \
    tar -xvf libpng-1.2.59.tar.gz; \
    cd /tmp/libpng-1.2.59; \
    ./configure --prefix=/usr/local; \
    make -j$(nproc); sudo make install;sudo ldconfig

# Tweak libstdc++.so.6 inside quartus http://www.stevesmuddlings.org/2015/09/test-post-1.html
WORKDIR /home/builder/intelFPGA_lite/17.1/quartus/linux64/
RUN sudo mv libstdc++.so.6 libstdc++.so.6.quartus_distrib; \
    sudo ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.6 libstdc++.so.6


RUN mkdir -p /home/builder/Desktop; ln -s /home/builder/intelFPGA_lite/17.1/quartus/bin/quartus /home/builder/Desktop

#build root RUN git checkout 2018.05.1 
#kernel -> git checkout rel_socfpga-4.9.78-ltsi_18.07.02_pr #Check your repository for the latest, in my case I went with this one
FROM builder as builder_runner
# Build the kernel
ENV CROSS_COMPILE=/home/builder/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

WORKDIR /home/builder/linux-socfpga
RUN git checkout rel_socfpga-4.9.78-ltsi_18.07.02_pr
#COPY linux.config .config
RUN make ARCH=arm socfpga_defconfig; \
    make ARCH=arm LOCALVERSION= zImage -j$(nproc)

# Build rootfs
WORKDIR /home/builder/buildroot
RUN git checkout 2018.05.1 
COPY default-config-files/buildroot.config .config
WORKDIR /home/builder
RUN make -C buildroot ARCH=ARM oldconfig; \
    make -C buildroot ARCH=ARM \
    -j$(nproc) \ 
    BR2_TOOLCHAIN_EXTERNAL_PATH=/home/builder/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf all

# Build uboot

# Build default example
RUN mkdir code
WORKDIR /home/builder/code
ADD src/custom_leds /home/builder/code/custom_leds
RUN sudo chown -R builder /home/builder/code/
WORKDIR /home/builder/code/custom_leds
#unable to run quartus at build stage it result with error Error (293007): Current module quartus_map ended unexpectedly. Verify that you have sufficient memory available to compile your design. You can view disk space and physical RAM requirements on the System and Software Requirements page of the Intel FPGA website (http://dl.altera.com/requirements/).
#I have tried with docker build . --memory=8G --memory-swap=8G and the memory max was increased but it doesn't seem to be the problem
#anyway I will left the binaries in the bin/ folder :(
#RUN quartus_sh --flow compile DE10_NANO_SoC_GHRD.qpf

#build linux-app for custom leds
WORKDIR /home/builder/code/custom_leds/linux-app/userspace
RUN make -j$(nproc)

WORKDIR /home/builder/code/custom_leds/linux-app/kernelspace
RUN make -j$(nproc) KDIR=/home/builder/linux-socfpga/

# Set output files
WORKDIR /home/builder
RUN mkdir output; \ 
    ln -s linux_socfpga/arch/arm/boot/zImage /home/builder/output/zImage; \
    ln -s buildroot/output/image/rootfs.tar /home/builder/output/rootfs.tar

#custom_leds output
RUN mkdir -p /home/builder/output/custom_leds
WORKDIR /home/builder/output/custom_leds
ADD bin/* /home/builder/output/custom_leds
RUN cp /home/builder/code/custom_leds/linux-app/kernelspace/custom_leds.ko custom_leds.ko
RUN cp /home/builder/code/custom_leds/linux-app/kernelspace/test_custom_leds.ko.sh test_custom_leds.ko.sh
RUN cp /home/builder/code/custom_leds/linux-app/userspace/devmem_demo devmem_demo

# RUN unzip DE10-Nano_v.1.3.8_HWrevC_SystemCD.zip -d DE10-Nano_SystemCD 
# # Build microSD here 
# #create fs
# #copy PreLoader into p0
# #copy rootfs into p1
# #copy u-boot.img u-boot.scr soc_system.dtb soc_system.rbf zImage into p2 FAT-fs

# Set env vars
ENV LIBGL_ALWAYS_INDIRECT=0
ENV GTK_IM_MODULE=fcitx
ENV QT_IM_MODULE=fcitx
ENV XMODIFIERS="@im=fcitx"
ENV DefaultIMModule=fcitx
ENV LC_ALL="en_US.UTF-8"
ENV LD_PRELOAD=/usr/lib/libtcmalloc_minimal.so.4

#change this with -e PASSWORD=password in the docker command or in docker-compose
ENV PASSWORD=builder
USER root
RUN echo "builder:builder" | chpasswd
RUN chmod +x /nxserver.sh

ENTRYPOINT ["/nxserver.sh"]