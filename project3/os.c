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

int _main() {
	initialFile();
	initialScreen(1);
	char * in;
	char * str;
	int tmp = -1;
	// dispatch(18432, 512);
	// initialScreen(0);
	do {
		in = getInput();
		if(in[0] == '.' && in[1] == '/')
		{
			tmp = find(in+2);
			if(tmp != -1 && information[tmp].deleted != 1){
				load(information[tmp].lmaddress, information[tmp].size, offsetOfUserPrg);
				dispatch(offsetOfUserPrg);
				clear();
			}
		}
		else if(in[0] == 't' && in[1] == 'y' &&
			in[2] == 'p' &&in[3] == 'e'){
			tmp = find(in+5);
			// if(tmp.type != null){
			if(tmp != -1 && information[tmp].deleted != 1){
				load(information[tmp].lmaddress, information[tmp].size, offsetOfUserPrg);
				str = getRecords(offsetOfUserPrg);
				printSentence(str, line, 0, strlen(str));
				line += countLines(str);
			}
		}
		else if(in[0] == 'r' && in[1] == 'm'){
			tmp = find(in+3);
			if(tmp != -1 && information[tmp].deleted != 1){
				information[tmp].deleted = 1;
			}
		}
		else {
			if(strcmp(in, "reboot") == 0)
				reboot();
			if(strcmp(in, "clear") == 0)
				clear();
			if(strcmp(in, "date") == 0)
				date();
			if(strcmp(in, "man") == 0)
				man();
			if(strcmp(in, "ls") == 0)
				ls();
		}
		newline();
	}while(strcmp(in, "exit") != 0);
	shutdown();
	return 0;
}


