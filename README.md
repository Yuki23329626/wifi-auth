# wifi-auth

soft ap in ubuntu 16.04  
需要兩張網卡，一張給內網、一張給外網

## 一個指令搞定所有安裝 + iptables 設定
總之就是先執行腳本,在bash輸入以下指令：
```bash
sudo sh wifi-ap.sh
```

關於 shell script 內用到的檔案，  
都需要事先改好 network interface 的名稱  
在我的電腦上 wlp2s0 是在內網的 interface  
而 wlxf48ceb9ba387 是連接外網的 interface  
具體要怎麼查詢，請使用下列 command:  
```bash
ifconfig
```
ip address 為 10. 或是 192. 開頭的通常會作為內網分配的 IP 使用  
lo 是 localhost 的介面  
剩下的就是可以連到 internet 的介面與實體線路的介面  
實體線路不會有 IPv4 的 address 應該不難分辨  

## 安裝 mysql
mysql的部份需要手動安裝  
sudo apt install mysql  

帳密我是用 root 跟 secret 做帳密  

開機啟動mysql服務  
```bash
sudo systemctl start mysql.service
sudo systemctl enable mysql.service
```
## 匯入 mysql 資料
匯入資料的 SQL 請參照 repository 內的 'db_init_sql.txt' 檔案內容  
基本上就是進入 mysql 的 command line 之後直接複製貼上就行了  

## mysql 帳密
進入 mysql cmd，使用'root'這個帳號，並且要輸入密碼，我是用'secret'做密碼  
若需要改帳號密碼，則相關的 auth.cpp 等檔案的帳密也需要修改  
```bash
mysql -u root -p
```