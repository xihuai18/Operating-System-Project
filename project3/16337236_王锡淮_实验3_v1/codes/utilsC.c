#include "utilsC.h"
#include "utilsAsm.h"


extern int line;

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
	line = 0;
	ClearScreen();
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

char * input()
{
	char * in = getInput();
	return in;
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
	char * manual = getManual();
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

extern struct info information[Len];
extern struct info no;

void initialFile()
{
	for(int i = 0; i < Len; ++i){
		information[i].type=null;
	}
	no.lmaddress = 0;
	no.size = 0;
	no.type = null;
	strcpy("", no.name);
	struct info A;
	A.lmaddress = 18432;
	A.size = 512;
	A.type = exec;
	strcpy("ball_A", A.name);
	struct info B;
	B.lmaddress = 18944;
	B.size = 512;
	B.type = exec;
	strcpy("ball_B", B.name);
	struct info C;
	C.lmaddress = 19456;
	C.size = 512;
	C.type = exec;
	strcpy("ball_C", C.name);
	struct info D;
	D.lmaddress = 19968;
	D.size = 512;
	D.type = exec;
	strcpy("ball_D", D.name);
	hash("ball_A" ,A);
	hash("ball_B", B);
	hash("ball_C", C);
	hash("ball_D", D);

	struct info P;
	P.lmaddress = 20480;
	P.size = 3072;
	P.type = exec;
	strcpy("printBigname", P.name);
	hash("printBigname", P);
}

void strcpy(char * sour, char * des)
{
	int i = 0;
	while(sour[i]){
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

void hash(char * key, struct info record)
{
	int inicode = hashfun(key);
	int code = inicode, i = 1;
	while(information[code].type!=null){
		code = (inicode + i * i) % Len;
		++i;
	}
	information[code] = record;
}

struct info find(char * key)
{
	int inicode = hashfun(key);
	int code = inicode, i = 1;
	while(information[code].type == null || strcmp(key, information[code].name) != 0){
		code = (inicode + i * i) % Len;
		++i;
		if(i > Len)
			return no;
	}
	return information[code];
}



void ls()
{
	char * head = "Name           size           Lma            Type";
	char typeTable[10][1] = {"N", "D", "E", "F"};
	printSentence(head, line, 10, strlen(head));
	line += countLines(head);
	char tmp[15];
	for(int i = 0; i < Len; ++i) 
	{
		if(information[i].type != null) {
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