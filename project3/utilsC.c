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
}

int program2Address(char * name)
{

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