#!/bin/bash

: ${MASSSTORAGE_SIZE:=536870912}
: ${MASSSTORAGE_IMAGE:=/piusb.bin}

truncate -s $MASSSTORAGE_SIZE "$MASSSTORAGE_IMAGE"
parted --align optimal --script "$MASSSTORAGE_IMAGE" -- \
    mklabel msdos \
    mkpart primary fat32 0% 100%
lo_dev=$(losetup --show --partscan -f "$MASSSTORAGE_IMAGE")
trap "losetup -d $lo_dev" EXIT
mkfs.vfat ${lo_dev}p1

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
