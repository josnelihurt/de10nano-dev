#/bin/bash

readonly SD_DEV="/dev/mmcblk0p1"
readonly RAW_FPGA_BINARY="soc_system.rbf"
readonly DEVICE_TREE_BINARY="soc_system.dtb"
readonly UBOOT_IMG="u-boot.img"

# Script functions
usage () {
    echo "Update DE10-nano fpga fpga configuration for u-boot config
          this script will copy some files to $SD_DEV 
          that partition is a FAT partition that holds the boot files
          Each file provided will be transfered to the device and
          it will be renamed as listed in the options, so it doesn't matter
          the original name
Usage:
    $(basename $0) [options]
    -r   rfb file     $RAW_FPGA_BINARY
    -d   dev tree bin $DEVICE_TREE_BINARY
    -u   uboot file   $UBOOT_IMG
    -h   device target
Example:
    $(basename $0) -h 192.168.0.13"
    exit ${1:-0}
}

transfer_file () {
    org=$1
    dest=$2
    if [ -f $org ]; then
        scp $file_org_rfg root@$host:/tmp/transfer/files/$RAW_FPGA_BINARY
    else
        echo "file $org not found on local fs"
    fi
}

# Exit with usage if no params received
[[ ! "$*" ]] && usage 1

# Parse options
file_org_rfg=""
file_org_dtb=""
file_org_uboot=""
host="socfpga"
while getopts ":r:d:h:u:" opt; do
    case $opt in
        h) host=$OPTARG ;;
        r) file_org_rfg=$OPTARG ;;
        d) file_org_dtb=$OPTARG ;;
        u) file_org_uboot=$OPTARG ;;
        \?) usage 1 ;;
    esac
done
shift $(($OPTIND - 1));     # take out the option flags

if [ -z "$host" ] ;then
    echo "missing host"
    usage 1
fi

echo "Connecting to ssh root@$host to transfer => $file_org_rfg $file_org_dtb $file_org_uboot"

echo "creating tmp file structure"
ssh root@$host 'mkdir -p /tmp/transfer/FAT; mkdir -p /tmp/transfer/files;mount /dev/mmcblk0p1 /tmp/transfer/FAT'
if [ ! -z "$file_org_rfg" ] ;then
    transfer_file $file_org_rfg $RAW_FPGA_BINARY
fi
if [ ! -z "$file_org_dtb" ] ;then
    transfer_file $file_org_dtb $DEVICE_TREE_BINARY
fi
if [ ! -z "$file_org_uboot" ] ;then
    transfer_file $file_org_uboot $UBOOT_IMG
fi
echo "delete tmp structure"
ssh root@$host 'mv /tmp/transfer/files/* /tmp/transfer/FAT;umount /tmp/transfer/FAT;rm -rf /tmp/transfer'
echo "done"

