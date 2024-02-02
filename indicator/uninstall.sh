#!/bin/bash

set -e

systemctl --user stop kugiigi.indicatordarkmode.service
systemctl --user disable kugiigi.indicatordarkmode.service

rm /home/phablet/.config/systemd/user/kugiigi.indicatordarkmode.service
rm /home/phablet/.local/share/ayatana/indicators/kugiigi.indicatordarkmode.indicator

echo "indicator-darkmode uninstalled"
