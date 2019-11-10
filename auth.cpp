#include <iostream>
#include <vector>
#include <string>
#include <stdlib.h>
#include <mysql.h>
#include <regex>
#include <map>

using namespace std;

map<string, string> Parse(const string& qstr){
	map<string, string> mapUser;
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

	MYSQL mysql;
	mysql_init(&mysql);
	int res;
	MYSQL_RES *result;
	MYSQL_ROW sql_row;
	
	if(!mysql_real_connect(&mysql, "localhost", "root", "secret", "wifi_auth", 3306, NULL, 0)){
		cout<< "\nError connecting to database\n" << mysql_error(&mysql) <<"\n\n";
	}else{
		cout<<"Connected!\n";
		
		//mysql_query(&mysql, "SET NAMES UTF8");

		string qstr = getenv(varNames[13].c_str());
		cout << "<BR>" << qstr <<"<BR>";
		map<string, string> mapUser = Parse(qstr);
		
		//cout <<"<BR>mapUser.first: "<< mapUser.first <<"<BR>";
		//cout <<"<BR>mapUser: "<< mapUser["name"] <<"<BR>";
		auto iterUser = mapUser.find("user");
		if(iterUser != mapUser.end()){
			cout << "<BR>mapUser[\"user\"]: "<< iterUser->second <<"<BR>";
		}
		
		auto iterPass = mapUser.find("pass");
		if(iterPass != mapUser.end()){
			cout << "<BR>mapUser[\"password\"]: "<< iterPass->second <<"<BR>";
		}

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
				if((iterPass->second) == (sql_row[2])){
					cout << "<BR>login success!<BR>";
					string strRemoteAddr(getenv(varNames[3].c_str()));
					string str1 = "sudo iptables -I FORWARD -s " + strRemoteAddr + "-j ACCEPT";
					string str2 = "sudo iptables -I FORWARD -d " + strRemoteAddr + "-j ACCEPT";
					cout << "<BR> str1 = " + str1 + "<BR>";
					cout << "<BR> str2 = " + str2 + "<BR>";
					const char* cmd1 = str1.c_str();
					const char* cmd2 = str2.c_str();
					int return1 = system(cmd1);
					int return2 = system(cmd2);
					// int return3 = system("echo 1");
					cout << "<BR>system(cmd1) retruns " << WEXITSTATUS( return1 ) << "<BR>";
					cout << "<BR>system(cmd2) returns " << WEXITSTATUS( return2 ) << "<BR>";
					// cout << "<BR>system(cmd3) returns " << WEXITSTATUS( return3 ) << "<BR>";
				}else{
					cout << "<BR>login failed!<BR>";
				}
			}
		}
	}

return 0;

}
