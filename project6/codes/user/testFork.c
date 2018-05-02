#define white 0x0f
#define NULL 0
__asm__(".code16gcc\n");
__asm__("mov %cs, %eax\n");
__asm__("mov %ax, %ds\n");
__asm__("mov %ax, %es\n");
__asm__("mov %ax, %ss\n");
__asm__("jmp __main\n");
#include "stdlib.h"
#include "stdio.h"
char str[80] = "Hello My Os!";

int count = 0;
char tmpstr[20];
struct testMalloc
{
	int i;
	struct testMalloc * next;
};
int ret;
int _main()
{
	char tmpstr[10];

	struct testMalloc * first = (struct testMalloc *)(malloc(sizeof(struct testMalloc)));
	if(first == 0)
	{
		printSentence("error", 11, 0, 5, white);
	}
	// first->i = 1;
	// first->next = (struct testMalloc *)(malloc(sizeof(struct testMalloc)));
	// first->next->i = 2; 
	// first->next->next = NULL;

	// struct testMalloc * one = first;
	struct testMalloc * p = first;
	int i = 0;
	for (int i = 0; i < 10; ++i)
	{
		p->i = i;
		p->next = (struct testMalloc *)(malloc(sizeof(struct testMalloc)));
		p = p->next;
	}

	p = first;
	while(p){
		int2str(p->i, tmpstr);
		printSentence(tmpstr, 10+p->i, 0, 1, white);
		p = p->next;
	}


	int line = 0;
	int pid;
	printSentence(str, line++, 0, strlen(str), white);
	pid = fork();

	if(pid == -1)
	{
		printSentence("Error in fork\r\n", line++, 0, strlen("Error in fork\r\n"), white);
	} else if(pid > 0) {
		ret = wait();
		printSentence("Number of letter in str is ", ++line, 0, strlen("Number of letter in str is "), white);
		int2str(count, tmpstr);
		printSentence(tmpstr, line, strlen("Number of letter in str is "), strlen(tmpstr), white);
		printSentence("\r\n", line++, 0, strlen("\r\n"), white);
		int2str(ret, tmpstr);
		printSentence("The returned value is ", line, 0, strlen("The returned value is "), white);
		printSentence(tmpstr, line, strlen("The returned value is "), strlen(tmpstr), white);
		printSentence("\r\n", line++, 0, strlen("\r\n"), white);
	} else {
		printSentence("\r\nSubprogram is counting the number...\r\n", line, 0, strlen("Subprogram is counting the number...\r\n"), white);
		count = strlen(str);
		exitprg(1);
	}
	getchar();
	exitprg(0);
}