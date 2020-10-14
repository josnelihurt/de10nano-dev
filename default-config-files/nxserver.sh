#!/bin/sh
echo builder':'$PASSWORD | chpasswd
chown builder /home/builder/external_src
/etc/NX/nxserver --startup
tail -f /usr/NX/var/log/nxserver.log