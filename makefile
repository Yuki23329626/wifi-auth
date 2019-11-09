# 會使用到 mysql 的 library，記得先安裝完成 mysql
all: auth.cpp
	g++ -std=c++11 -I/usr/include/mysql /home/nxshen/wifi-auth/auth.cpp -L/usr/lib/mysql -lmysqlclient -o /usr/lib/cgi-bin/auth.cgi
clean:
	rm auth.cgi
