#!/bin/bash
# Progra:
# This program is for testing
# History:
# 2019/11/2 nxshen First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo "\nHello there, it a shell script for testing\n"

LAN_INTERFACE=wlp2s0

ifconfig $LAN_INTERFACE up

exit 0
