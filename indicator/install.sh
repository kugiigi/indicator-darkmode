#!/bin/bash

set -e

mkdir -p /home/phablet/.config/upstart/
mkdir -p /home/phablet/.local/share/unity/indicators/

cp -v /opt/click.ubuntu.com/indicator-darkmode.kugiigi/current/indicator/kugiigi-indicator-darkmode.conf /home/phablet/.config/upstart/
cp -v /opt/click.ubuntu.com/indicator-darkmode.kugiigi/current/indicator/com.kugiigi.indicator.darkmode /home/phablet/.local/share/unity/indicators/

echo "indicator-darkmode installed!"
