#!/bin/bash

echo start massstorage

set -e

: ${MASSSTORAGE_SIZE:=536870912}
: ${MASSSTORAGE_IMAGE:=/piusb.bin}

# Enable dwc2 driver
echo "dtoverlay=dwc2" >> /boot/config.txt
echo "dwc2" >> /etc/modules

tmp_dir="$(mktemp -d)"
trap "rm -rf $tmp_dir" EXIT

# Create/partition image file
truncate -s $MASSSTORAGE_SIZE "$MASSSTORAGE_IMAGE"
parted --align optimal --script "$MASSSTORAGE_IMAGE" -- \
    mklabel msdos \
    mkpart primary fat32 0% 100%

# Hack to avoid losetup which doesn't seem to work here for some reason
fdisk_output="$(fdisk --list --bytes -o Start "$MASSSTORAGE_IMAGE")"
start_sectors=$(echo "$fdisk_output" | grep -A1 '^Start' | tail -n1 | awk '{$1=$1};1')
sector_size=$(echo "$fdisk_output" | grep '^Units' | awk '{print $(NF-1)}')
start_bytes=$(( $start_sectors * $sector_size ))

# Second file is just the partition
part_image="$tmp_dir/part"
truncate -s $(( $MASSSTORAGE_SIZE - $start_bytes )) "$part_image"
mkfs.vfat "$part_image"

dd if="$part_image" of="$MASSSTORAGE_IMAGE" seek=$start_sectors bs=$sector_size conv=sparse,notrunc


cat >/etc/systemd/system/massstorage.service <<EOF

[Unit]
Description=MassStorage
After=network.target

[Service]
Type=oneshot
ExecStart=modprobe g_mass_storage file=$MASSSTORAGE_IMAGE
WorkingDirectory=/
StandardOutput=inherit
StandardError=inherit
Restart=no
User=root

[Install]
WantedBy=multi-user.target

EOF

systemctl enable massstorage.service

echo end massstorage
