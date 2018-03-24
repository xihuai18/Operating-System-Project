#include "utilsC.h"
#include "utilsAsm.h"

// __asm__(".code16gcc\n");
__asm__("mov $0, %eax\n");
__asm__("mov %ax, %ds\n");
__asm__("mov %ax, %es\n");
__asm__("jmpl $0, $__main\n");

int line = 0;
char * exitSen = "exit";
char * rebootSen = "reboot";
char * clearSen = "clear";
char * dateSen = "date";
char * manSen = "man";

int _main() {
	initialScreen(1);
	char * in;
	// dispatch(18432, 512);
	// initialScreen(0);
	do {
		in = input();
		if(strcmp(in, rebootSen) == 0)
			reboot();
		if(strcmp(in, clearSen) == 0)
			clear();
		if(strcmp(in, dateSen) == 0)
			date();
		if(strcmp(in, manSen) == 0)
			man();
		newline();
	}while(strcmp(in, exitSen) != 0);
	shutdown();

	return 0;
}


