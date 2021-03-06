#!/bin/bash
# Progra:
# This program will set up a wifi access point with a web-based authentication and also set up the iptables.
# History:
# 2019/11/8 nxshen add several comments
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo "\nHello there, it's a shell script for establishing a wifi access point~\n"

# 設定網卡ID(以下腳本會用到的變數)
LAN_INTERFACE=wlp2s0
WAN_INTERFACE=wlxd037453d9c6a

echo "\n-- checking for necessary packages --\n"

# 安裝 apache2、mysql-server(也可以直接安裝 lamp-server^)、
# 安裝 dhcp-server(動態分配內網 IP 的 server)、dnsmasq(DNS server)

# PKG_OK=$(dpkg-query -W --showformat='${Status}\n' lamp-server^|grep "install ok installed")
# echo Checking for lamp-server^: $PKG_OK
# if [ "" = "$PKG_OK" ]
# then
#   echo "Have not installed. Start installing..."
#   sudo apt install lamp-server^
# fi
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' apache2|grep "install ok installed")
echo Checking for apache2: $PKG_OK
if [ "" = "$PKG_OK" ]
then
  echo "Have not installed. Start installing..."
  sudo apt install -y apache2
fi
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' mysql-server|grep "install ok installed")
echo Checking for mysql-server: $PKG_OK
if [ "" = "$PKG_OK" ]
then
  echo "Have not installed. Start installing..."
  sudo apt install -y mysql-server
fi
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' isc-dhcp-server|grep "install ok installed")
echo Checking for isc-dhcp-server: $PKG_OK
if [ "" = "$PKG_OK" ]
then
  echo "Have not installed. Start installing..."
  sudo apt install -y isc-dhcp-server
fi
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' dnsmasq|grep "install ok installed")
echo Checking for dnsmasq: $PKG_OK
if [ "" = "$PKG_OK" ]
then
  echo "Have not installed. Start installing..."
  sudo apt install dnsmasq
fi
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' libmysql++-dev|grep "install ok installed")
echo Checking for libmysql++-dev: $PKG_OK
if [ "" = "$PKG_OK" ]
then
  echo "Have not installed. Start installing..."
  sudo apt install -y libmysql++-dev
fi
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' hostapd|grep "install ok installed")
echo Checking for hostapd: $PKG_OK
if [ "" = "$PKG_OK" ]
then
  echo "Have not installed. Start installing..."
  sudo apt install -y hostapd
fi

echo "\n-- start copying files --\n"

# 把 config files 直接放到他們該在的地方，記得修改各自 config file 內的網卡名稱設定
cp auth.cpp /usr/lib/cgi-bin/
cp auth.cgi /usr/lib/cgi-bin/
cp makefile /usr/lib/cgi-bin/
# 要先安裝完成 mysql 用的 library "libmysql++-dev" 才能成功編譯，auth.cpp 會用到 "libmysql++-dev"
make
sudo cp envvars /etc/apache2/
sudo cp dhcpd.conf /etc/dhcp/
sudo cp hostapd.conf /etc/hostapd/
sudo cp bookmarks.html /home/
sudo cp setIptables /home/
sudo cp index.html /var/www/html/
sudo cp isc-dhcp-server /etc/default/
sudo cp dhcpd.conf /etc/dhcp/
sudo cp interfaces /etc/network/
#sudo cp dnsmasq.conf /etc/
sudo cp NetworkManager.conf /etc/NetworkManager/

echo "\n-- start and enable services --\n"

# 啟動該啟動的服務們並且設為開機啟動
sudo echo "1" > /proc/sys/net/ipv4/ip_forward
sudo ifconfig $LAN_INTERFACE 10.10.0.1/24 up
systemctl start apache2.service
systemctl enable apache2.service
systemctl start isc-dhcp-server.service
systemctl enable isc-dhcp-server.service
systemctl start mysql.service
systemctl enable mysql.service
#systemctl start dnsmasq.service
#systemctl enable dnsmasq.service
sudo ufw allow  67/udp
sudo ufw reload
#sudo systemctl restart networking
sudo service network-manager stop
sudo service network-manager start

#sudo /etc/init.d/dnsmasq restart

# 允許 apache 啟用 cgi 的 module，要 restart 才會生效
sudo a2enmod cgi
sudo service apache2 restart


# 驗證網頁是: 10.10.0.1/index.html，應該也可以設定 /etc/hosts 來給他一個名稱
# 以下六行清空所有iptables的規則
iptables -Z
iptables -F
iptables -X
iptables -t nat -Z
iptables -t nat -F
iptables -t nat -X

# 下面的暫時用不到了，留著作紀念
# iptables 防火牆設定，有滿多是沒用的設定，本來想用類似 DNS 綁架的方式重導向驗證網頁，不知道怎麼設定~
# 以下設定的 code 取自 wifidog iptables 設定，一樣記得修改網卡ID
# Reference url: http://blog.changyy.org/2017/02/captive-portal-iptables.html
# iptables -P INPUT ACCEPT
# iptables -P FORWARD ACCEPT
# iptables -P OUTPUT ACCEPT
# iptables -N WD_wlan0_AuthServs
# iptables -N WD_wlan0_Global
# iptables -N WD_wlan0_Internet
# iptables -N WD_wlan0_Known
# iptables -N WD_wlan0_Locked
# iptables -N WD_wlan0_Unknown
# iptables -N WD_wlan0_Validate
# iptables -A FORWARD -i wlxf48ceb9ba387 -j WD_wlan0_Internet
# iptables -A FORWARD -i $LAN_INTERFACE -o $WAN_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
# iptables -A FORWARD -i $WAN_INTERFACE -o $LAN_INTERFACE -j ACCEPT
# iptables -A WD_wlan0_AuthServs -d 10.10.0.1/32 -j ACCEPT
# iptables -A WD_wlan0_Internet -m state --state INVALID -j DROP
# iptables -A WD_wlan0_Internet -o $LAN_INTERFACE -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
# iptables -A WD_wlan0_Internet -j WD_wlan0_AuthServs
# iptables -A WD_wlan0_Internet -m mark --mark 0x254 -j WD_wlan0_Locked
# iptables -A WD_wlan0_Internet -j WD_wlan0_Global
# iptables -A WD_wlan0_Internet -m mark --mark 0x1 -j WD_wlan0_Validate
# iptables -A WD_wlan0_Internet -m mark --mark 0x2 -j WD_wlan0_Known
# iptables -A WD_wlan0_Internet -j WD_wlan0_Unknown
# iptables -A WD_wlan0_Known -j ACCEPT
# iptables -A WD_wlan0_Locked -j REJECT --reject-with icmp-port-unreachable
# iptables -A WD_wlan0_Unknown -p udp -m udp --dport 53 -j ACCEPT
# iptables -A WD_wlan0_Unknown -p tcp -m tcp --dport 53 -j ACCEPT
# iptables -A WD_wlan0_Unknown -p udp -m udp --dport 67 -j ACCEPT
# iptables -A WD_wlan0_Unknown -p tcp -m tcp --dport 67 -j ACCEPT
# iptables -A WD_wlan0_Unknown -j REJECT --reject-with icmp-port-unreachable
# iptables -A WD_wlan0_Validate -j ACCEPT

# 把所有經過 filter forward chain 目標是 $WAN_INTERFACE 這個 interface 的封包全部丟掉
iptables -A FORWARD -o $WAN_INTERFACE -j REJECT


# 允許 NAT 上的 IP 可以轉換成外部IP(規則:MASQUERADE)，與外網溝通
iptables --table nat --append POSTROUTING --out-interface $WAN_INTERFACE -j MASQUERADE

# 啟用hostapd服務
hostapd /etc/hostapd/hostapd.conf

exit 0
