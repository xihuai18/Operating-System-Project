#include <stdio.h>
int main()
{
	int ds, a=1;
	__asm__("mov %ds, %eax\n");
	__asm__("pushl %eax");
	__asm__("popl %0":"=m"(ds));
	printf("%d\n", ds);
	return 0;
}