#!/bin/bash

[ -z "$1" ] && echo "Usage: ${0##*/} CHROMECAST_IP [DNS_over_TCP_SERVER]" && exit 1
DNS_SERVER="${2:-base.dns.mullvad.net}"

# Ensure ADB server is running and suppress all output
adb devices &>/dev/null

# Try connecting until successful, suppress unnecessary output
while ! adb connect "$1" 2>&1 | grep -q "connected to"; do
    echo "Waiting for device to be available..."
    sleep 1
done
echo "Device connected!"

echo
echo "Configuring DNS..."
adb shell settings put global private_dns_mode hostname
adb shell settings put global private_dns_specifier "$DNS_SERVER"

DNS_MODE="$(adb shell settings get global private_dns_mode)"
DNS_SPECIFIER="$(adb shell settings get global private_dns_specifier)"
[ "$DNS_MODE" = "hostname" ] && [ "$DNS_SPECIFIER" = "$DNS_SERVER" ] && echo "DNS configured!" && exit 0
echo "Couldn't configure DNS!" && exit 2
