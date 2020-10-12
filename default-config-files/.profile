# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n
export LC_ALL="en_US.UTF-8"
export LD_PRELOAD=/usr/lib/libtcmalloc_minimal.so.4
export CROSS_COMPILE=/home/builder/gcc-linaro-7.1.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
export PATH=$PATH:/home/builder/intelFPGA_lite/17.1/quartus/bin
alias l='ls -alF'
alias ll='ls -alF'
alias ..='cd ..'

if [ -f /root/.profile.addons ]; then
    source /root/.profile.addons
fi