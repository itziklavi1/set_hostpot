#!/bin/bash
#Configure the following as you like
SSID="itzik_hotspot"     		# The SSID of your new Access Point
PSK="my_secret123456789"    		# The password to join the Access Point
APN="my.provider.apn"  	# The APN of the provider of your SIM card 

set -e

if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

echo -e "#####    apt: update system"
apt -y update
apt -y upgrade

echo -e "#####    apt: install NetworkManager package"
apt -y install network-manager
echo -e "#####    apt: purge conflicting package"
apt -y purge openresolv dhcpcd5 

# Hotspot creation
echo -en "#####    nmcli: Create wifi connection... "
nmcli connection add type wifi ifname wlan0 con-name Hotspot autoconnect yes ssid $SSID
echo "done"

echo -en "#####    nmcli: Configure connection as wifi access point... "
nmcli connection modify Hotspot 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
echo "done"

echo -en "#####    nmcli: Configure connection security... " 
nmcli connection modify Hotspot wifi-sec.key-mgmt wpa-psk
echo "done"

echo -en "#####    nmcli: Define access point password (psk)... "
nmcli connection modify Hotspot wifi-sec.psk $PSK
echo "done"

# Create mobile modem connection
#echo -en "#####    nmcli: create mobile modem connection... "
#sudo nmcli connection add type gsm ifname cdc-wdm0 con-name mobile apn $APN
#echo "done"

# Inibizione della porta ethernet come default gateway
echo -en "#####    nmcli: inhibit eth0 as default gateway... "
nmcli connection mod eth0 ipv4.never-default true autoconnect yes
echo "done"

echo -en "\n#####    ALL DONE: REBOOTING NOW\n"
reboot
