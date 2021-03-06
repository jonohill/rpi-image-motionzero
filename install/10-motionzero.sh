#!/bin/bash

echo Start motionzero

set -e

apt-get update
apt-get install -y \
    ffmpeg \
    git \
    python3-pip

cd /tmp
git clone https://github.com/jonohill/rpizero-arlo
cd rpizero-arlo
git checkout "$MZ_VERSION"
mv /tmp/rpizero-arlo/sender /opt/motionzero
mkdir /tmp/piusb

cd /opt/motionzero
chown -R pi:pi /opt/motionzero
pip3 install -r requirements.txt

mkdir /etc/motionzero
touch /etc/motionzero/env

cat >/etc/systemd/system/motionzero.service <<EOF

[Unit]
Description=MotionZero
After=network.target

[Service]
ExecStart=/opt/motionzero/run.sh
WorkingDirectory=/opt/motionzero
EnvironmentFile=/etc/motionzero/env
StandardOutput=inherit
StandardError=inherit
Restart=always

[Install]
WantedBy=multi-user.target

EOF

systemctl enable motionzero.service

echo End motionzero
