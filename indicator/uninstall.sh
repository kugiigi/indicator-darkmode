#!/bin/bash

set -e

rm /home/phablet/.config/upstart/kugiigi-indicator-darkmode.conf
rm /home/phablet/.local/share/unity/indicators/com.kugiigi.indicator.darkmode

echo "indicator-darkmode uninstalled"
