#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install usbutils ethtool kmod can-utils -y

modprobe pcan_usb || true
