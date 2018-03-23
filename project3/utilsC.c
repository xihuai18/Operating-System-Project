#include "utilsC.h"
#include "utilsAsm.h"

extern int line;

// __asm__(".code16gcc\n");

char * WelcomeSentence = "oh my Wsh\n\rCopyright (C) Xihuai Wang\n\r";
char * prompt = "\n\r>>";

// 注意字符串要有'0'结尾。
int strlen(char * sen)
{
	int i = 0;
	while(sen[i]) { ++i; }
	return i;
}

void initialScreen()
{
	ClearScreen();
	printSentence(WelcomeSentence, 0, line, strlen(WelcomeSentence));
	line += 2;
	printSentence(prompt, 2, line++, strlen(prompt));
}

char * input()
{
	char * in = getInput();
	printSentence(prompt, line++, 0, strlen(prompt));
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