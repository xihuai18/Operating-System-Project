#define white 0x0f
#include "stdlib.h"
#include "stdio.h"
__asm__(".code16gcc\n");
__asm__("mov %cs, %eax\n");
__asm__("mov %ax, %ds\n");
__asm__("mov %ax, %es\n");
__asm__("mov %ax, %ss\n");
__asm__("jmp __main\n");

int _main()
{
	char text[] = "testing multiple terminal";
	for (int i = 0; i < 20; ++i)
	{
		printSentence(text, i, 0, strlen(text), white);
		for (int j = 0; j < 100000; ++j)
		{}
	}
	return 0;
}