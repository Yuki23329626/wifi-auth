# 用來編譯 auth.cpp 程式的 makefile
# 會使用到 mysql 的 library "libmysql++-dev"，記得先安裝完成 "libmysql++-dev"
all: auth.cpp
	g++ -std=c++11 -I/usr/include/mysql auth.cpp -L/usr/lib/mysql -lmysqlclient -o /usr/lib/cgi-bin/auth.cgi
clean:
	rm auth.cgi
