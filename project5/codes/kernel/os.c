#include "../lib/utilsC.h"
#include "../lib/utilsAsm.h"


__asm__(".code16gcc\n");
__asm__("mov %cs, %eax\n");
__asm__("mov %ax, %ds\n");
__asm__("mov %ax, %es\n");
__asm__("mov %ax, %ss\n");
__asm__("call _inisys\n");
__asm__("jmp __main\n");

int line = 0;
struct info information[Len];
struct info no;
struct MemoryBlock memoryTable[MemLen]; 
int firstUnusedMemoryItem = 0;
short *FAT;
struct Process processTable[Len];
int curProcessId;
int ProcessSize;
int runSub;
int SizeOfProcessStruct;
//id 为-1意为空,processTable[0]为内核.

int _main() {
	runSub = 0;
	curProcessId = 0;
	ProcessSize = 1;
	SizeOfProcessStruct = sizeof(struct Process);
	initial();
	char * in;
	char * str;
	int tmp = -1;

	// __asm__("mov $0x0, %ah\n");
	// test();


	do {
		in = getInput();
		if(in[0] == 'r' && in[1] == 'u' && in[2] == 'n')
		{
			printSentence("\n", line++, 0, strlen("\n"), white);
			do{
				str = getInput();
				printSentence("\n", line++, 0, strlen("\n"), white);
				if(str[0]){	
					tmp = find(str);
					if(tmp != -1 && information[tmp].deleted != 1){
						createProcess(ProcessSize++, information[tmp].name, information[tmp].size+1024, tmp);
					}
				}
			}while(str[0] != '\0');

			runSub = 1;
			wakeUp();
			__asm__("int $0x8\n");
			// runSub = 0;
			clear();
		}
		else if(in[0] == '.' && in[1] == '/')
		{
			tmp = find(in+2);
			if(tmp != -1 && information[tmp].deleted != 1){
				createProcess(ProcessSize++, information[tmp].name, information[tmp].size+1024, tmp);
				// dispatch(&(processTable[0]), &(processTable[curProcessId]));
				runSub = 1;
				__asm__("int $0x8\n");
				// runSub = 0;
				clear();
			}
		}
		else if(in[0] == 't' && in[1] == 'y' &&
			in[2] == 'p' &&in[3] == 'e'){
			tmp = find(in+5);
			if(tmp != -1 && information[tmp].deleted != 1){
				loadReal(information[tmp].lmaddress, information[tmp].size, offsetOfUserPrg, segOfOs);
				str = getRecords(segOfUser, offsetOfUserPrg);
				printSentence(str, line, 0, strlen(str), purple);
				line += countLines(str);
			}
		}
		else if(in[0] == 'r' && in[1] == 'm'){
			tmp = find(in+3);
			if(tmp != -1 && information[tmp].deleted != 1){
				information[tmp].deleted = 1;
			}
		}
		else if(in[0] == 'k' && in[1] == 'i' &&
			in[2] == 'l' && in[3] == 'l'){
			kill(in[5]-'0');
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
			if(strcmp(in, "exit") == 0)
				shutdown();
			if(strcmp(in, "ps") == 0)
				ps();
		}
		newline();
	}while(1);
	return 0;
}


