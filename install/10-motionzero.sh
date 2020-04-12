#!/bin/bash

echo Start motionzero

set -e

apt-get update
apt-get install -y \
    git \
    python3-pip

cd /tmp
git clone https://github.com/jonohill/rpizero-arlo
cd rpizero-arlo
git checkout "$MZ_VERSION"
mv /tmp/rpizero-arlo/sender /opt/motionzero

cd /opt/motionzero
chown -R pi:pi /opt/motionzero
su pi
pip3 install -r requirements.txt
exit

cat >/etc/systemd/system/motionzero.service <<EOF

[Unit]
Description=MotionZero
After=network.target

[Service]
ExecStart=/usr/bin/python3 -u main.py
WorkingDirectory=/opt/motionzero
StandardOutput=inherit
StandardError=inherit
Restart=always
User=pi

[Install]
WantedBy=multi-user.target

EOF

systemctl enable motionzero.service

echo End motionzero
