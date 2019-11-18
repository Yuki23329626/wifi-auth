#include <iostream>
#include <vector>
#include <string>
#include <stdlib.h>
#include <mysql.h>
#include <regex>
#include <map>

using namespace std;

// 因為我不想浪費時間學 perl，所以我用 c++ 來寫ˊˇˋ

// 把網址裡面的兩個變數傳進來，拆成 username 跟 password 放進 map 裡，回傳 map<string, string>
map<string, string> Parse(const string& qstr){
	map<string, string> mapUser;
	// 例如網址後面是 key1=value1&key2=value2 會被拆成 key1, value1 一組， key2, value2 一組
	regex pattern("([\\w+%]+)=([^&]*)");
	auto words_begin = sregex_iterator(qstr.begin(), qstr.end(), pattern);
	auto words_end = sregex_iterator();
	
	for(sregex_iterator i = words_begin; i != words_end; i++){
		string name = (*i)[1].str();
		string password = (*i)[2].str();
		mapUser[name] = password;
	}
	
	return mapUser;
}
			
 
int main()
{
    // 可以呼叫的環境變數
    string strNames[]={
      "DOCUMENT_ROOT",
      "GATEWAY_INTERFACE",
      "HTTP_HOST",
      "REMOTE_ADDR",
      "REMOTE_PORT",
      "REQUEST_METHOD",
      "REQUEST_URI",
      "SCRIPT_FILENAME",
      "SERVER_ADDR",
      "SERVER_NAME",
      "SERVER_PORT",
      "SERVER_PROTOCOL",
      "SERVER_SOFTWARE",
      "QUERY_STRING",
      "HTTP_COOKIE"
    };


    vector<string> varNames(strNames, strNames+15);

    cout << "Content-type:text/html\r\n\r\n";
    cout << "<html>";
    cout << "<head>";
    cout << "<title>Envrionment Variables</title>";
    cout << "</head>";
    cout << "<body>";
    cout << "<table border = \"1\" cellspacing = \"0\">";

		// 印出環境變數比較好觀察
    for (int i = 0; i < varNames.size(); ++i)
    {
        cout << "<tr><td>" << varNames[i] << "</td><td>";
        const char *value = getenv(varNames[i].c_str());
        if (value != NULL) {
            cout << value;
        } else {
            cout << "Not exist";
        }
        cout << "</td></tr>";
    }
    cout << "</table>";
    cout << "</body>";
    cout << "</html>";
  
	// mysql 連線的初始化設定
	MYSQL mysql;
	mysql_init(&mysql);
	int res;
	MYSQL_RES *result;
	MYSQL_ROW sql_row;
	
	if(!mysql_real_connect(&mysql, "localhost", "root", "secret", "wifi_auth", 3306, NULL, 0)){
		cout<< "\nError connecting to database\n" << mysql_error(&mysql) <<"\n\n";
	}else{
		cout<<"MySQL database Connected!\n";
		
		//mysql_query(&mysql, "SET NAMES UTF8");

		string qstr = getenv(varNames[13].c_str());
		cout << "<BR>" << qstr <<"<BR>";
		map<string, string> mapUser = Parse(qstr);
		
		//cout <<"<BR>mapUser.first: "<< mapUser.first <<"<BR>";
		//cout <<"<BR>mapUser: "<< mapUser["name"] <<"<BR>";

		// 印出網址裡的 "user" 對應的 value
		auto iterUser = mapUser.find("user");
		if(iterUser != mapUser.end()){
			cout << "<BR>mapUser[\"user\"]: "<< iterUser->second <<"<BR>";
		}
		
		// 印出網址裡的 "pass" 對應的 value
		auto iterPass = mapUser.find("pass");
		if(iterPass != mapUser.end()){
			cout << "<BR>mapUser[\"password\"]: "<< iterPass->second <<"<BR>";
		}

		// SQL語法，找出跟網址裡一樣的 user name
		mysql_query(&mysql, "use wifi_auth");
		string dbQuery = "select * from user where name=\'"+ iterUser->second +"\'";

		//string strQuery = "select * from user";
		//res = mysql_query(&mysql, "select * from user");
		res = mysql_query(&mysql, dbQuery.c_str());
		if(!res){
			result = mysql_store_result(&mysql);
			if(result){
				/*cout << "<table border = \"1\" cellspacing = \"0\">";
				while(sql_row = mysql_fetch_row(result)){
					cout << "<TR><TD>" << sql_row[1] << "</TD>";
					cout << "<TD>" << sql_row[2] << "</TD></TR>";
				}*/
				sql_row = mysql_fetch_row(result);

				// 如果找到 user name 之後，比對成功的話，就會進入下面的 block，印出成功訊息並且設定 iptables
				if((iterPass->second) == (sql_row[2])){
					cout << "<BR>login success!<BR>";
					string strRemoteAddr(getenv(varNames[3].c_str()));
					// iptables 在 filter 的 forward chain 插入規則: 只要 source ip 跟 destination ip 是 remote address，就通過
					string str1 = "sudo iptables -I FORWARD -s " + strRemoteAddr + " -j ACCEPT";
					string str2 = "sudo iptables -I FORWARD -d " + strRemoteAddr + " -j ACCEPT";
					cout << "<BR> str1 = " + str1 + "<BR>";
					cout << "<BR> str2 = " + str2 + "<BR>";
					const char* cmd1 = str1.c_str();
					const char* cmd2 = str2.c_str();
					int return1 = system(cmd1);
					int return2 = system(cmd2);
					// int return3 = system("echo 1");
					cout << "<BR>system(cmd1) retruns " << return1 << "<BR>";
					cout << "<BR>system(cmd2) returns " << return2 << "<BR>";
					// cout << "<BR>system(cmd3) returns " << WEXITSTATUS( return3 ) << "<BR>";
				}else{
					cout << "<BR>login failed!<BR>";
				}
			}
		}
	}

return 0;

}
