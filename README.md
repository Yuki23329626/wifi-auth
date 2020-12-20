# wifi-auth  
Transform your laptop into a wifi AP with a login page.  

soft ap in ubuntu 16.04  
需要兩張網卡，一張給內網、一張給外網  

學校筆電因為裝了 nvidia 顯卡，ubuntu 16.x 會卡開機畫面  
解決方法：https://itsfoss.com/fix-ubuntu-freezing/  
1. 進到開機 USB 選單，press 'e' 進入 grub 畫面
2. 編輯開頭是 linux 的那一行，最後面 "---" 改成 "nomodeset" 這個字串  

個人建議不要用 ubuntu 18.x 的版本來練習，各種神奇的 features  

## 1. 一個指令搞定所有安裝 + iptables 設定

關於 shell script 內用到的檔案，  
都需要事先改好 network interface 的名稱  
在我的電腦上 wlp2s0 是在內網的 interface  
而 wlxf48ceb9ba387 是連接外網的 interface  
具體要怎麼查詢，請使用下列 command:  
```bash
ifconfig -a
```
ip address 為 10. 或是 192. 開頭的通常會作為內網分配的 IP 使用  
lo 是 localhost 的介面  
剩下的就是可以連到 internet 的介面與實體線路的介面  
實體線路沒插線設定不會有 IPv4 的 address 應該不難分辨  

可能需要更改 interface id 的檔案：  
 - hostapd.conf
 - interfaces
 - isc-dhcp-server
 - wifi-ap.sh  
 - NetworkManager.conf

以上檔案都需要設定內網網卡 ID，只有 wifi-ap.sh 需要再設定外網網卡 ID，NetworkManager.conf 要新增 mac address  
wlp2s0 是我內網網卡的 ID，新電腦可能都一樣，舊電腦可能會叫做 wlan0 之類的  

在設定完所有檔案的 interface id 之後，即可執行腳本:  
```bash
sudo sh wifi-ap.sh
```

## 2. apache 權限設定

apache 部份相關檔案需要手動設定  
```bash
sudo visudo
```

在檔案裡加上這一行:  
```bash
www-data  ALL=(ALL)NOPASSWD:/sbin/iptables
```

這個動作的目的是要讓 apache 在 linux 系統裡的身分(www-data)  
有權限去執行 auth.cgi 裡面的 system() iptables 設定  

## 3. 匯入 mysql 資料

匯入資料的 SQL 請參照 repository 內的 'db_init_sql.txt' 檔案內容  
基本上就是進入 mysql 的 command line 之後直接複製貼上就行了  

## 4. mysql 帳密

進入 mysql cmd，使用'root'這個帳號，並且要輸入密碼，我是用'secret'做密碼  
若需要改帳號密碼，則相關的 auth.cpp 等檔案的帳密也需要修改  
```bash
mysql -u root -p
```
