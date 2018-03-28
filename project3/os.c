#include "utilsC.h"
#include "utilsAsm.h"



// __asm__(".code16gcc\n");
__asm__("mov $0, %eax\n");
__asm__("mov %ax, %ds\n");
__asm__("mov %ax, %es\n");
__asm__("jmpl $0, $__main\n");

int line = 0;
struct info information[Len];
struct info no;
// struct record res[Len];
// struct Control con;
// struct record root;

char * exitSen = "exit";
char * rebootSen = "reboot";
char * clearSen = "clear";
char * dateSen = "date";
char * manSen = "man";
char * lsSen = "ls";

int _main() {
	initialFile();
	initialScreen(1);
	char * in;
	char * str;
	struct info tmp = no;
	// dispatch(18432, 512);
	// initialScreen(0);
	do {
		in = input();
		if(in[0] == '.' && in[1] == '/')
		{
			tmp = find(in+2);
			if(tmp.type != null){
				load(tmp.lmaddress, tmp.size, offsetOfUserPrg);
				dispatch(offsetOfUserPrg);
				clear();
			}
			tmp = no;
		}
		else if(in[0] == 't' && in[1] == 'y' &&
			in[2] == 'p' &&in[3] == 'e'){
			tmp = find(in+5);
			if(tmp.type != null){
				load(tmp.lmaddress, tmp.size, offsetOfUserPrg);
				str = getRecords(offsetOfUserPrg);
				printSentence(str, line, 0, strlen(str));
				line += countLines(str);
			}
			tmp = no;
		}
		else {
			if(strcmp(in, rebootSen) == 0)
				reboot();
			if(strcmp(in, clearSen) == 0)
				clear();
			if(strcmp(in, dateSen) == 0)
				date();
			if(strcmp(in, manSen) == 0)
				man();
			if(strcmp(in, lsSen) == 0)
				ls();
		}
		newline();
	}while(strcmp(in, exitSen) != 0);
	shutdown();
	return 0;
}


