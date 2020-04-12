#!/bin/bash

set -e

echo start motionzero

: ${MZ_KEY:=test}
: ${MZ_URL:=}

cat >/etc/motionzero/env <<EOF
MZ_KEY=${MZ_KEY}
MZ_URL=${MZ_URL}
EOF

echo end motionzero
