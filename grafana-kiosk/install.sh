#!/bin/bash

set -eu

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# https://github.com/grafana/grafana-kiosk#installing-on-linux
ARCH="armv7"

# install some utilities
sudo apt-get -y install \
    chromium-browser \
    jq \
    unclutter

# install latest grafana-kiosk
latest_info=$(curl -s https://api.github.com/repos/grafana/grafana-kiosk/releases/latest)
download_url=$(echo ${latest_info} | jq -r ".assets[] | select(.name | contains(\"${ARCH}\")) | .browser_download_url")
curl -OL ${download_url}
sudo cp -p grafana-kiosk.linux.${ARCH} /usr/bin/grafana-kiosk
sudo chmod 755 /usr/bin/grafana-kiosk

# change the display resolution to 1920x1080
# https://www.raspberrypi.org/documentation/computers/config_txt.html#hdmi_mode
sudo sed -i 's/#hdmi_mode=1/hdmi_mode=82/' /boot/config.txt
