#include "utilsC.h"
#include "utilsAsm.h"

// __asm__(".code16gcc\n");
__asm__("mov $0, %eax\n");
__asm__("mov %ax, %ds\n");
__asm__("mov %ax, %es\n");
__asm__("jmpl $0, $__main\n");

int line = 0;
char * exitSen = "exit";

int _main() {
	initialScreen();
	char * in;
	do {
		in = input();
	}while(strcmp(in, exitSen) != 0);
	shutdown();

	return 0;
}


