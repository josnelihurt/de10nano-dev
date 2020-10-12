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

#################################################################################
## If you modify the upper lines you will lose the downloads so prepare coffee ##
#################################################################################

USER root
RUN apt-get -y install libfontconfig1 \
    libglib2.0-0    \
    libsm6  \
    libxrender1     \
    locales     \
    make    \
    xauth   \
    xvfb    \
    pkg-config  \
    libprotobuf-dev     \
    protobuf-compiler   \
    python-protobuf     \
    python3-pip     \
    libpng16-16     \
    udisks2 \
    nano    \
    vim \
    tmux    \
    file    \
    cpio    \
    rsync   \
    build-essential     \
    libncurses5-dev \
    bc  \
    xz-utils    \
    zip unzip   \
    sudo    

RUN pip3 install intelhex
# Set the locale, Quartus expects en_US.UTF-8
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Allow builder to sudo without password
RUN echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN usermod -aG sudo builder
USER builder

# Prepare permissions to install components
WORKDIR /home/builder
RUN chmod +x ModelSimSetup-17.1.0.590-linux.run \
    QuartusLiteSetup-17.1.0.590-linux.run \
    SoCEDSSetup-17.1.0.590-linux.run

# Install components 
RUN ./QuartusLiteSetup-17.1.0.590-linux.run --mode unattended --accept_eula 1 --disable-components quartus_help
RUN ./SoCEDSSetup-17.1.0.590-linux.run --mode unattended --accept_eula 1 \
    --installdir /home/builder/intelFPGA_lite/17.1/
# export quartus path
ENV PATH $PATH:/home/builder/intelFPGA_lite/17.1/quartus/bin

RUN ls -lah
RUN tar -xvf gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz; \
    tar -xvf gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz

#export CROSS_COMPILE=$PWD/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
#export CROSS_COMPILE=$PWD/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-


# Clean-up, you can extract this files from the container if you need it 
RUN mkdir downloads
RUN mv gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz downloads; \
    mv gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz downloads; \
    mv ModelSimSetup-17.1.0.590-linux.run downloads; \
    mv QuartusLiteSetup-17.1.0.590-linux.run downloads; \
    mv SoCEDSSetup-17.1.0.590-linux.run downloads

RUN unzip DE10-Nano_v.1.3.8_HWrevC_SystemCD.zip -d DE10-Nano_SystemCD 
RUN mv DE10-Nano_v.1.3.8_HWrevC_SystemCD.zip downloads

RUN echo "Installation completed, this is the list of files"
RUN ls -lah


# Install additional packages for quartus 
RUN sudo apt-get install -y locales \
    libtcmalloc-minimal4    \
    libglib2.0-0    \
    apt-utils   \
    xfce4   \
    caja    \
    fcitx-mozc  \
    dbus-x11    \
    x11-xserver-utils   \
    xfce4-terminal  

USER root
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
    ENV TERM=xterm-color
USER builder

# Build and install libpng used by quartus
WORKDIR /tmp
RUN wget https://netactuate.dl.sourceforge.net/project/libpng/libpng12/1.2.59/libpng-1.2.59.tar.gz
RUN tar -xvf libpng-1.2.59.tar.gz
RUN ls -lah
WORKDIR /tmp/libpng-1.2.59
RUN ./configure --prefix=/usr/local
RUN make
USER root
RUN make install
RUN ldconfig
USER builder

# Install i386 dependencies
RUN sudo dpkg --add-architecture i386; \
    sudo apt-get update; \
    sudo apt-get install -y \
        libxft2:i386 \
        libxext6:i386 \
        libncurses5:i386 \
        libc6:i386 \
        libstdc++6:i386 \
        unixodbc-dev \
        lib32ncurses5-dev \
        libzmq3-dev \
        gtk2-engines-pixbuf:i386

# Tweak libstdc++.so.6 inside quartus http://www.stevesmuddlings.org/2015/09/test-post-1.html
WORKDIR /home/builder/intelFPGA_lite/17.1/quartus/linux64/
RUN sudo mv libstdc++.so.6 libstdc++.so.6.quartus_distrib; \
    sudo ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.6 libstdc++.so.6

# Install nxserver
RUN sudo apt-get clean && sudo apt-get update && \
    sudo apt-get update -y && \
    sudo apt-get install -y xterm libgconf2-4 iputils-ping libxss1 wget xdg-utils libpango1.0-0 fonts-liberation xfce4-goodies htop 
WORKDIR /home/builder/downloads
#this me change beaware
RUN wget "https://download.nomachine.com/download/6.12/Linux/nomachine_6.12.3_8_i386.deb"
RUN sudo dpkg -i nomachine_6.12.3_8_i386.deb && sudo sed -i "s|#EnableClipboard both|EnableClipboard both |g" /usr/NX/etc/server.cfg
RUN sudo apt-get install gnome-icon-theme
ADD default-config-files/nxserver.sh /nxserver.sh
ADD default-config-files/.profile /home/builder/.profile
RUN sudo chown -R builder /home/builder/.profile
ADD default-config-files/.config /home/builder/.config
RUN sudo chown -R builder /home/builder/.config
RUN mkdir /home/builder/.icons
RUN cp -r /usr/share/icons/* /home/builder/.icons
RUN sudo chown -R builder /home/builder/.icons
WORKDIR /home/builder/
RUN mkdir Desktop
RUN ln -s /home/builder/intelFPGA_lite/17.1/quartus/bin/quartus /home/builder/Desktop

#####################################################################################################
## If you modify the upper lines you will lose the system configuration and you will need a coffee ##
#####################################################################################################

# Build the kernel
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
COPY default-config-files/buildroot.config .config
WORKDIR /home/builder
RUN make -C buildroot ARCH=ARM oldconfig
RUN make -C buildroot ARCH=ARM \
        -j$(nproc) \ 
        BR2_TOOLCHAIN_EXTERNAL_PATH=/home/builder/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf all
# Build uboot


# Build default example
RUN mkdir code
WORKDIR /home/builder/code
COPY src/custom_leds /home/builder/code/custom_leds
RUN sudo chown -R builder /home/builder/code/
WORKDIR /home/builder/code/custom_leds
#RUN quartus_sh --flow compile DE10_NANO_SoC_GHRD.qpf


# Set output files
WORKDIR /home/builder
RUN mkdir output
RUN ln -s linux_socfpga/arch/arm/boot/zImage /home/builder/output/zImage
RUN ln -s buildroot/output/image/rootfs.tar /home/builder/output/rootfs.tar


# Set env vars
ENV LIBGL_ALWAYS_INDIRECT=0
ENV GTK_IM_MODULE=fcitx
ENV QT_IM_MODULE=fcitx
ENV XMODIFIERS="@im=fcitx"
ENV DefaultIMModule=fcitx
ENV LC_ALL="en_US.UTF-8"
ENV LD_PRELOAD=/usr/lib/libtcmalloc_minimal.so.4
#used if you wanna run on xserver and not inside xfce/nxserver
ENV DISPLAY=192.168.0.7:0

#change this with -e PASSWORD=password in the docker command or in docker-compose
ENV PASSWORD=builder
USER root
RUN echo "builder:builder" | chpasswd
ENTRYPOINT ["/nxserver.sh"]

#ENTRYPOINT ["/bin/bash"]
#ENTRYPOINT ["quartus"]