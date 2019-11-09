#!/bin/bash
# Progra:
# This program is for testing
# History:
# 2019/11/2 nxshen First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo "\nHello there, it a shell script for testing\n"

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' apache2|grep "install ok installed")
echo Checking for apache2: $PKG_OK

if [ "" = "$PKG_OK" ]
then
  echo "Have not installed. Start installing..."
  sudo apt install apache2
if

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' mysql|grep "install ok installed")
echo Checking for mysql: $PKG_OK

if [ "" = "$PKG_OK" ]
then
  echo "Have not installed. Start installing..."
  sudo apt install mysql
fi

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' isc-dhcp-server|grep "install ok installed")
echo Checking for isc-dhcp-server: $PKG_OK

if [ "" = "$PKG_OK" ]
then
  echo "Have not installed. Start installing..."
  sudo apt install isc-dhcp-server
fi

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' dnsmasq|grep "install ok installed")
echo Checking for dnsmasq: $PKG_OK

if [ "" = "$PKG_OK" ]
then
  echo "Have not installed. Start installing..."
  sudo apt install dnsmasq
fi


#LAN_INTERFACE=wlp2s0
#ifconfig $LAN_INTERFACE up

exit 0
