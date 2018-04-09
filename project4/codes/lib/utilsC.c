#include "utilsC.h"
#include "utilsAsm.h"


extern struct info information[Len];
extern struct info no;
extern int line;
extern struct Control con;
extern struct record root;
extern short* FAT;
extern struct Process processTable[Len];

__asm__(".code16gcc\n");

char * WelcomeSentence = "oh my Wsh\n\rCopyright (C) Xihuai Wang\n\rtype \"man\" to get help\n\r";
char * prompt = ">>";

// ×¢Òâ×Ö·û´®ÒªÓÐ'0'½áÎ²¡£
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
		printSentence(WelcomeSentence, line, 0, strlen(WelcomeSentence), white);
		line += countLines(WelcomeSentence);
	}
	printSentence(prompt, line, 0, strlen(prompt), white);
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
	printSentence(dateSen, line, 30, strlen(dateSen), purple);
	newline();
	line += countLines(dateSen);
}


void man()
{
	char * manual = getRecords(segOfOs, offsetOfManual);
	line = 0;
	ClearScreen();
	printSentence(manual, line, 0, strlen(manual), purple);
	line += countLines(manual);
}

void newline()
{
	if(line >= 25) {
		roll();
		line = 24;
	}
	printSentence(prompt, line, 0, strlen(prompt), white);
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


	information[code].type = record.type;
	strncpy(record.name, information[code].name, strlen(record.name));
	information[code].size = record.size;
	information[code].lmaddress = record.lmaddress;
	information[code].deleted = record.deleted;
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
	printSentence(head, line, 10, strlen(head), green);
	char typeTable[10][1] = {"N", "D", "E", "F"};
	line += countLines(head);
	char tmp[15];
	for(int i = 0; i < Len; ++i) 
	{
		if(information[i].type != null && information[i].deleted != 1) {
			printSentence(information[i].name, line, 10, strlen(information[i].name), purple);
			int2str(information[i].size, tmp);
			printSentence(tmp, line, 25, strlen(tmp), purple);
			int2str(information[i].lmaddress, tmp);
			printSentence(tmp, line, 40, strlen(tmp), purple);
			printSentence(typeTable[information[i].type], line, 55, 1, purple);
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
	if(org == 0)
		num = 1;
	str[num--] = '\0';
	for(int i = num; i >= 0; --i)
	{
		str[i] = org % 10 + 48;
		org /= 10;
	}
}

void initialFile()
{
	FAT = (short*)getRecords(segOfOs, offsetOfFat);
	for(int i = 0; i < Len; ++i){
		information[i].type=null;
	}
	no.lmaddress = 0;
	no.size = 0;
	no.type = null;
	strncpy("", no.name, 0);
	loadFiles();

}

struct info used;

void loadFiles()
{
	char * rawRecords = getRecords(segOfOs, offsetOfRecord);
	int i = 0;
	int l = 0;
	int size = 0;
	int place = 0;
	char name[30];
	enum fileType t = null;
	struct info *tmp = &used;
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
		name[l] = '\0';
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
		tmp->size = size;
		tmp->type = t;
		tmp->lmaddress = place;
		tmp->deleted = 0;
		strncpy(name, tmp->name, strlen(name));
		hash(name, *tmp);
	}
}

void createProcess(short cs, short ip, short ss, short sp, int id, char * name)
{
	processTable[id].id = id;
	processTable[id].pcb.cs = cs;
	processTable[id].pcb.ip = ip;
	processTable[id].pcb.ss_now = ss;
	processTable[id].pcb.sp_now = sp;
	processTable[id].status = ready;
	strncpy(name, processTable[id].name, strlen(name));
}

void initialProcessTable()
{
	for (int i = 0; i < Len; ++i)
	{
		processTable[i].id = -1;
		processTable[i].status = Origin;
	}
	createProcess(0x2000, 0, 0x2000, 0xffff, 0, "kernel");
	processTable[0].status = running;
}

void ps()
{
	char * head = "Id  ProcessName\n";
	printSentence(head, line++, 29, strlen(head), purple);
	char str[30];
	for (int i = 0; i < Len; ++i)
	{
		if(processTable[i].id != -1)
		{
			int2str(processTable[i].id, str);
			printSentence(str, line, 30, strlen(str), purple);
			printSentence(processTable[i].name, line++, 34, strlen(processTable[i].name), purple);
		}
	}
}

void kill(int id)
{
	processTable[id].status = exit;
	processTable[id].id = -1;
}

void int34h()
{
	char * s = "Int 34h Xihuai Wang";
	printSentence(s, 6, 5, strlen(s), purple);
}
void int35h()
{
	char * s = "Int 35h 16337236";
	printSentence(s, 6, 46, strlen(s), purple);
}
void int36h()
{
	char * s = "Int 34h Class two";
	printSentence(s, 18, 5, strlen(s), purple);
}
void int37h()
{
	char * s = "Int 34h Grade 2016";
	printSentence(s, 18, 46, strlen(s), purple);
}
