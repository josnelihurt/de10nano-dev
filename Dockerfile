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
    lib32ncurses5-dev libzmq3-dev gtk2-engines-pixbuf:i386; \
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
    libpango1.0-0 fonts-liberation xfce4-goodies htop gnome-icon-theme \
    gparted mount dosfstools bless geany

ENV DOWNLOADER_SRV=localhost
ENV DOWNLOADER_PORT=8080

RUN wget http://${DOWNLOADER_SRV}:${DOWNLOADER_PORT}/nomachine_6.12.3_8_i386.deb; \
    dpkg -i nomachine_6.12.3_8_i386.deb && \
    sudo sed -i "s|#EnableClipboard both|EnableClipboard both |g" /usr/NX/etc/server.cfg; \
    rm nomachine_6.12.3_8_i386.deb

####################################################################################################################################
FROM debian-nxserver as builder

# Allow builder to sudo without password
RUN echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN usermod -aG sudo builder

USER builder
ENV TERM=xterm-color

ADD default-config-files/.profile /home/builder/.profile
ADD default-config-files/.config /home/builder/.config
RUN sudo chown -R builder /home/builder/.profile; sudo chown -R builder /home/builder/.config; \
    mkdir -p /home/builder/.icons; \
    cp -r /usr/share/icons/* /home/builder/.icons; \
    sudo chown -R builder /home/builder/.icons; \
    mkdir -p /home/builder/downloads

WORKDIR /home/builder/downloads
# Install components 
# Build and install libpng used by quartus
WORKDIR /tmp
RUN wget https://netactuate.dl.sourceforge.net/project/libpng/libpng12/1.2.59/libpng-1.2.59.tar.gz; \
    tar -xvf libpng-1.2.59.tar.gz; \
    rm -rf libpng-1.2.59.tar.gz; \
    cd /tmp/libpng-1.2.59; \
    ./configure --prefix=/usr/local; \
    make -j$(nproc); sudo make install;sudo ldconfig; \
    cd /tmp; rm -rf /tmp/libpng-1.2.59;
    
RUN \
    wget http://${DOWNLOADER_SRV}:${DOWNLOADER_PORT}/SoCEDSSetup-17.1.0.590-linux.run; \
    chmod +x SoCEDSSetup-17.1.0.590-linux.run; \
    ./SoCEDSSetup-17.1.0.590-linux.run --mode unattended --accept_eula 1 --installdir /home/builder/intelFPGA_lite/17.1/; \
    rm SoCEDSSetup-17.1.0.590-linux.run ;
RUN \
    wget http://${DOWNLOADER_SRV}:${DOWNLOADER_PORT}/ModelSimSetup-17.1.0.590-linux.run; \
    wget http://${DOWNLOADER_SRV}:${DOWNLOADER_PORT}/QuartusLiteSetup-17.1.0.590-linux.run; \
    wget http://${DOWNLOADER_SRV}:${DOWNLOADER_PORT}/Quartus-lite-17.1.0.590-linux.tar; \
    wget http://${DOWNLOADER_SRV}:${DOWNLOADER_PORT}/cyclonev-17.1.0.590.qdz; \
    chmod +x ModelSimSetup-17.1.0.590-linux.run; \
    chmod +x QuartusLiteSetup-17.1.0.590-linux.run; \
    ./QuartusLiteSetup-17.1.0.590-linux.run --mode unattended --accept_eula 1 --disable-components quartus_help; \
    rm -rf *; 
WORKDIR /home/builder
RUN \
    cd /home/builder; \
    wget http://${DOWNLOADER_SRV}:${DOWNLOADER_PORT}/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz; \
    tar -xvf gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz; \
    rm gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz; 

RUN \    
    wget http://${DOWNLOADER_SRV}:${DOWNLOADER_PORT}/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz; \
    tar -xvf gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz; \
    rm gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz; 

# export quartus path
ENV PATH $PATH:/home/builder/intelFPGA_lite/17.1/quartus/bin
#export CROSS_COMPILE=$PWD/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
#export CROSS_COMPILE=$PWD/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

# Tweak libstdc++.so.6 inside quartus http://www.stevesmuddlings.org/2015/09/test-post-1.html
WORKDIR /home/builder/intelFPGA_lite/17.1/quartus/linux64/
RUN sudo mv libstdc++.so.6 libstdc++.so.6.quartus_distrib; \
    sudo ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.6 libstdc++.so.6

RUN mkdir -p /home/builder/Desktop; ln -s /home/builder/intelFPGA_lite/17.1/quartus/bin/quartus /home/builder/Desktop

#################################################
#build root RUN git checkout 2018.05.1 
#kernel -> git checkout rel_socfpga-4.9.78-ltsi_18.07.02_pr #Check your repository for the latest, in my case I went with this one
FROM builder as builder_runner
# Download repositories

ENV CROSS_COMPILE=/home/builder/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

# Build rootfs
WORKDIR /home/builder/
RUN git clone git://git.buildroot.net/buildroot
WORKDIR /home/builder/buildroot
RUN git checkout 2018.05.1 
COPY default-config-files/buildroot.config .config
WORKDIR /home/builder
RUN make -C buildroot ARCH=ARM oldconfig; \
    make -C buildroot ARCH=ARM \
    -j$(nproc) \ 
    BR2_TOOLCHAIN_EXTERNAL_PATH=/home/builder/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf all

# Build the kernel
WORKDIR /home/builder/
RUN git clone https://github.com/altera-opensource/linux-socfpga.git
WORKDIR /home/builder/linux-socfpga
RUN git checkout rel_socfpga-4.9.78-ltsi_18.07.02_pr
#COPY linux.config .config
RUN make ARCH=arm socfpga_defconfig; \
    make ARCH=arm LOCALVERSION= zImage -j$(nproc)

# Build uboot
WORKDIR /home/builder/
RUN git clone https://github.com/altera-opensource/u-boot-socfpga.git; \
    cd u-boot-socfpga; \
    git checkout rel_socfpga_v2013.01.01_17.08.01_pr; 
RUN cd /home/builder/; \    
    wget http://${DOWNLOADER_SRV}:${DOWNLOADER_PORT}/gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf.tar.xz; \
    tar -xvf gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf.tar.xz; \
    rm gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf.tar.xz;
#Just to build uboot 
ENV CROSS_COMPILE=/home/builder/gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
RUN cd u-boot-socfpga; \
    make mrproper; \
    make socfpga_cyclone5_config; \
    make; 

ENV CROSS_COMPILE=/home/builder/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
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
RUN sudo apt-get install -y u-boot-tools;\
    cd /home/builder/code/custom_leds/bootscript/; \
    mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "Boot Script Name" -d boot.script u-boot.scr


#build linux-app for custom leds
WORKDIR /home/builder/code/custom_leds/linux-app/userspace
RUN make -j$(nproc)

WORKDIR /home/builder/code/custom_leds/linux-app/kernelspace
RUN make -j$(nproc) KDIR=/home/builder/linux-socfpga/

#Download sd img
WORKDIR /home/builder
RUN mkdir /home/builder/output;
WORKDIR /home/builder/output
RUN wget http://${DOWNLOADER_SRV}:${DOWNLOADER_PORT}/de10_nano_linux_console.zip;

# Set output files
WORKDIR /home/builder
RUN mkdir /home/builder/output; \ 
    cp /home/builder/linux-socfpga/arch/arm/boot/zImage /home/builder/output/zImage; \
    cp /home/builder/code/custom_leds/bootscript/u-boot.scr /home/builder/output/u-boot.scr; \
    cp /home/builder/u-boot-socfpga/u-boot.img /home/builder/output/u-boot.img; \
    cp /home/builder/buildroot/output/images/rootfs.tar /home/builder/output/rootfs.tar; 

#custom_leds output
RUN mkdir -p /home/builder/output/custom_leds
WORKDIR /home/builder/output/custom_leds
ADD bin/custom_leds/* /home/builder/output/custom_leds/
RUN cp /home/builder/code/custom_leds/linux-app/kernelspace/custom_leds.ko custom_leds.ko; \
    cp /home/builder/code/custom_leds/linux-app/kernelspace/test_custom_leds.ko.sh test_custom_leds.ko.sh; \
    cp /home/builder/code/custom_leds/linux-app/userspace/devmem_demo devmem_demo; \
    cp /home/builder/code/custom_leds/software/spl_bsp/preloader-mkpimage.bin /home/builder/output/preloader-mkpimage.bin;



# #create fs
# #copy PreLoader into p0
# #copy rootfs into p1
# #copy u-boot.img u-boot.scr soc_system.dtb soc_system.rbf zImage into p2 FAT-fs

#/home/builder/intelFPGA_lite/17.1/embedded/embedded_command_shell.sh 

# Final packages
RUN sudo apt-get install -y nano

# Set env vars
ENV LIBGL_ALWAYS_INDIRECT=0
ENV GTK_IM_MODULE=fcitx
ENV QT_IM_MODULE=fcitx
ENV XMODIFIERS="@im=fcitx"
ENV DefaultIMModule=fcitx
ENV LC_ALL="en_US.UTF-8"
ENV LD_PRELOAD=/usr/lib/libtcmalloc_minimal.so.4

# # Build microSD here 
WORKDIR /home/builder/output
ADD src/scripts/sd_img_creator.sh sd_img_creator.sh
#change this with -e PASSWORD=password in the docker command or in docker-compose
ENV PASSWORD=builder
USER root
ADD default-config-files/nxserver.sh /nxserver.sh
RUN echo "builder:builder" | chpasswd
RUN chmod +x /nxserver.sh
ENTRYPOINT ["/nxserver.sh"]
#################################################
FROM builder_runner as builder_micro_sd
USER root

WORKDIR /home/builder/output
RUN chmod +x sd_img_creator.sh; 

#ENTRYPOINT ["bash", "echo", "none"]
ENTRYPOINT ["/home/builder/output/sd_img_creator.sh"]