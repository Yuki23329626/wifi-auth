all: auth.cpp
	g++ -std=c++11 -I/usr/include/mysql auth.cpp -L/usr/lib/mysql -lmysqlclient -o auth.cgi
clean:
	rm auth.cgi
