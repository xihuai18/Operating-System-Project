#include "utilsC.h"
#include "utilsAsm.h"


extern struct info information[Len];
extern struct info no;
extern int line;
extern struct Control con;
extern struct record root;
// extern struct record res[Len];

// __asm__(".code16gcc\n");

char * WelcomeSentence = "oh my Wsh\n\rCopyright (C) Xihuai Wang\n\rtype \"man\" to get help\n\r";
char * prompt = ">>";

// 注意字符串要有'0'结尾。
int strlen(char * sen)
{
	int i = 0;
	while(sen[i]) { ++i; }
	return i;
}

int countLines(char * sen)
{
	int lines = 0;
	for(int i = 0; sen[i]; ++i) {
		if(sen[i] == '\n') {
			++lines;
		}
	}
	lines += 1;
	return lines;
}

void initialScreen(int welcome)
{
	clear();
	if(welcome) {
		printSentence(WelcomeSentence, line, 0, strlen(WelcomeSentence));
		line += countLines(WelcomeSentence);
	}
	printSentence(prompt, line, 0, strlen(prompt));
	line += countLines(prompt);
}

void clear()
{
	line = 0;
	ClearScreen();
}

int strcmp(char * l, char * r)
{
	int i=0, j=0;
	for(; l[i] && r[i]; ++i, ++j)
	{
		if(l[i] < r[j]) {
			return -1;
		} else if(l[i] > r[j]) {
			return 1;
		} 
	}
	if(!l[i] && r[j]) {
		return -1;
	} else if(l[i] && !r[j]) {
		return 1;
	} else {
		return 0;
	}
}

void date()
{
	char * dateSen = getDate();
	printSentence(dateSen, line, 30, strlen(dateSen));
	line += countLines(dateSen);
}


void man()
{
	char * manual = getRecords(offsetOfManual);
	line = 0;
	ClearScreen();
	printSentence(manual, line, 0, strlen(manual));
	line += countLines(manual);
}

void newline()
{
	if(line >= 25) {
		roll();
		line = 24;
	}
	printSentence(prompt, line, 0, strlen(prompt));
	line += countLines(prompt);
}



void strncpy(char * sour, char * des, int len)
{
	int i = 0;
	while(sour[i] && i < len){
		des[i] = sour[i];
		++i;
	}
	des[i] = '\0';
}

int hashfun(char * key){
	int weight = 29;
	int i = 0;
	int ret = 0;
	while(key[i]){
		ret = (ret + key[i]*weight) % Len;
		++i;
	}
	return ret;
}

int hash(char * key, struct info record)
{
	int inicode = hashfun(key);
	int code = inicode, i = 1;
	while(information[code].type!=null){
		code = (inicode + i * i) % Len;
		++i;
	}
	information[code] = record;
	return code;
}

int find(char * key)
{
	int inicode = hashfun(key);
	int code = inicode, i = 1;
	while(information[code].type == null || strcmp(key, information[code].name) != 0){
		code = (inicode + i * i) % Len;
		++i;
		if(i > Len)
			return -1;
	}
	return code;
}

void ls()
{
	char * head = "Name           Size           Lma            Type";
	char typeTable[10][1] = {"N", "D", "E", "F"};
	printSentence(head, line, 10, strlen(head));
	line += countLines(head);
	char tmp[15];
	for(int i = 0; i < Len; ++i) 
	{
		if(information[i].type != null && information[i].deleted != 1) {
			printSentence(information[i].name, line, 10, strlen(information[i].name));
			int2str(information[i].size, tmp);
			printSentence(tmp, line, 25, strlen(tmp));
			int2str(information[i].lmaddress, tmp);
			printSentence(tmp, line, 40, strlen(tmp));
			printSentence(typeTable[information[i].type], line, 55, 1);
			line += 1;
		}
	}
}

void int2str(int org, char * str)
{
	int num = 0;
	int cp = org;
	while(cp != 0)
	{
		cp /= 10;
		++num;
	}
	str[num--] = '\0';
	for(int i = num; i >= 0; --i)
	{
		str[i] = org % 10 + 48;
		org /= 10;
	}
}

void initialFile()
{
	for(int i = 0; i < Len; ++i){
		information[i].type=null;
	}
	no.lmaddress = 0;
	no.size = 0;
	no.type = null;
	strncpy("", no.name, 0);
	loadFiles();
}

void loadFiles()
{
	char * rawRecords = getRecords(offsetOfRecord);
	int i = 0;
	int l = 0;
	int size = 0;
	int place = 0;
	char name[30];
	enum fileType t = null;
	struct info tmp;
	while(rawRecords[i] != '\n')
	{
		size = 0;
		place = 0;
		// name
		++i;
		l = 0;
		while(rawRecords[i]!='|'){
			++i;
			++l;
		}
		++i;
		strncpy(rawRecords+i-l-1, name, l);
		// size
		while(rawRecords[i]!='|'){
			size = size * 10 + rawRecords[i]-'0';
			++i;
		}		
		++i;
		// place
		while(rawRecords[i]!='|'){
			place = place * 10 + rawRecords[i]-'0';
			++i;
		}		
		++i;
		//type
		t = rawRecords[i]-'0';
		i+=3;
		tmp.size = size;
		tmp.type = t;
		tmp.lmaddress = place;
		tmp.deleted = 0;
		strncpy(name, tmp.name, strlen(name));
		hash(name, tmp);
	}
}

// void initialFile()
// {
// 	for(int i = 0; i < Len; ++i){
// 		information[i].type=null;
// 	}
// 	no.lmaddress = 0;
// 	no.size = 0;
// 	no.type = null;
// 	strcpy("", no.name);
// 	struct info A;
// 	A.lmaddress = 18432;
// 	A.size = 512;
// 	A.type = exec;
// 	strcpy("ball_A", A.name);
// 	struct info B;
// 	B.lmaddress = 18944;
// 	B.size = 512;
// 	B.type = exec;
// 	strcpy("ball_B", B.name);
// 	struct info C;
// 	C.lmaddress = 19456;
// 	C.size = 512;
// 	C.type = exec;
// 	strcpy("ball_C", C.name);
// 	struct info D;
// 	D.lmaddress = 19968;
// 	D.size = 512;
// 	D.type = exec;
// 	strcpy("ball_D", D.name);
// 	hash("ball_A" ,A);
// 	hash("ball_B", B);
// 	hash("ball_C", C);
// 	hash("ball_D", D);

// 	struct info P;
// 	P.lmaddress = 20480;
// 	P.size = 3072;
// 	P.type = exec;
// 	strcpy("printBigname", P.name);
// 	hash("printBigname", P);
// }


// void initialFile()
// {
// 	con.used = 18432;
// 	con.unused = 24376;
// 	strncpy("root", root.name, 4);
// 	root.type = folder;
// 	root.deleted = 0;
// 	root.info_index = -1;
// 	root.father_folder=-1;
// 	root.sibling = -1;
// 	root.son = 1;
// 	loadFiles();
// }
// void loadFiles()
// {
// 	char * rawRecords = getRecords();
// 	int son = root.son;
// 	int i = 0;
// 	int l = 0;
// 	int size = 0;
// 	int place = 0;
// 	enum fileType t = null;
// 	while(rawRecords[i] != '\n')
// 	{
// 		// name
// 		++i;
// 		l = 0;
// 		while(rawRecords[i]!='|'){
// 			++l;
// 		}
// 		++i;
// 		strncpy(rawRecords+i-1, res[son].name, l);
// 		// size
// 		l = 1;
// 		while(rawRecords[i]!='|'){
// 			size = size * l + rawRecords[i]-'0';
// 			l *= 10;
// 		}		
// 		++i;
// 		// place
// 		l = 1;
// 		while(rawRecords[i]!='|'){
// 			place = place * l + rawRecords[i]-'0';
// 			l *= 10;
// 		}		
// 		++i;
// 		t = rawRecords[i]-'0';
// 		i+=2;
// 		res[son].type = t;
// 		res[son].deleted = 0;
// 		res[son].father_folder = 0;
// 		res[son].sibling = son+1;
// 		res[son].son = -1;
// 		struct info re;
// 		re.lmaddress = place;
// 		re.size = size;
// 		res[son].info_index = hash(res[son].name, re);
// 		son += 1;
// 	}
// }
// void loadFiles()
// {
// 	char * rawRecords = getRecords();
// 	int son = root.son;
// 	int i = 0;
// 	int l = 0;
// 	int size = 0;
// 	int place = 0;
// 	enum fileType t = null;
// 	while(rawRecords[i] != '\n')
// 	{
// 		// name
// 		++i;
// 		l = 0;
// 		while(rawRecords[i]!='|'){
// 			++l;
// 		}
// 		++i;
// 		strncpy(rawRecords+i-1, res[son].name, l);
// 		// size
// 		l = 1;
// 		while(rawRecords[i]!='|'){
// 			size = size * l + rawRecords[i]-'0';
// 			l *= 10;
// 		}		
// 		++i;
// 		// place
// 		l = 1;
// 		while(rawRecords[i]!='|'){
// 			place = place * l + rawRecords[i]-'0';
// 			l *= 10;
// 		}		
// 		++i;
// 		t = rawRecords[i]-'0';
// 		i+=2;
// 		res[son].type = t;
// 		res[son].deleted = 0;
// 		res[son].father_folder = 0;
// 		res[son].sibling = son+1;
// 		res[son].son = -1;
// 		struct info re;
// 		re.lmaddress = place;
// 		re.size = size;
// 		res[son].info_index = hash(res[son].name, re);
// 		son += 1;
// 	}
// }
