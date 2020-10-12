#!/bin/sh
echo builder':'$PASSWORD | chpasswd
/etc/NX/nxserver --startup
tail -f /usr/NX/var/log/nxserver.log