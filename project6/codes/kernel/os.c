#include "../lib/utilsC.h"
#include "../lib/utilsAsm.h"


__asm__(".code16gcc\n");
__asm__("mov %cs, %eax\n");
__asm__("mov %ax, %ds\n");
__asm__("mov %ax, %es\n");
__asm__("mov %ax, %ss\n");
__asm__("mov %ax, %gs\n");
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
struct Queue ReadyQue;
struct Queue BlockedQue;
//id 为-1意为空,processTable[0]为内核.

struct testMalloc
{
	int i;
	struct testMalloc * next;
};

int _main() {
	runSub = 0;
	curProcessId = 0;
	ProcessSize = 1;
	SizeOfProcessStruct = sizeof(struct Process);
	initial();
	char * in;
	char * str;
	int tmp = -1;
	init(&ReadyQue);
	init(&BlockedQue);

	// __asm__("mov $0x0, %ah\n");
	// test();
	// struct testMalloc * first = (struct testMalloc *)(malloc(sizeof(struct testMalloc)));
	// if(first == 0)
	// {
	// 	printSentence("error", 11, 0, 5, white);
	// }
	// first->i = 1;
	// first->next = (struct testMalloc *)(malloc(sizeof(struct testMalloc)));
	// first->next->i = 2; 
	// first->next->next = NULL;

	// struct testMalloc * one = first;
	// char tmpstr[10];
	// while(one){
	// 	int2str(one->i, tmpstr);
	// 	printSentence(tmpstr, 10, 0, 1, white);
	// 	one = one->next;
	// }


	do {
		in = getInput();
		if(strcmp(in, "testFork") == 0){
			tmp = find(in);
			int offsetOfPrg, segOfPrg;
			int offsetMask = 0x0000ffff;
			int segMask = 0xf0000;
			offsetOfPrg = 0x80000 & offsetMask;
			segOfPrg = (0x80000 & segMask) >> 4;
			int cs = segOfPrg + (offsetOfPrg >> 4), ip = 0, ss = segOfPrg + (offsetOfPrg >> 4), sp = information[tmp].size+1024-1;
			createProcess(ProcessSize++, information[tmp].name, information[tmp].size+1024, cs, ip, ss, sp, 8);
			enqueue(&ReadyQue, ProcessSize-1);
			clear();
			runSub = 1;
			__asm__("int $0x8\n");
			runSub = 0;
			clear();
		}
		else if(in[0] == 'r' && in[1] == 'u' && in[2] == 'n')
		{
			printSentence("\n", line++, 0, strlen("\n"), white);
			do{
				str = getInput();
				printSentence("\n", line++, 0, strlen("\n"), white);
				if(str[0]){	
					tmp = find(str);
					if(tmp != -1 && information[tmp].deleted != 1){
						int blockNum = findEnoughBlock(information[tmp].size+1024);
						blockNum = require(information[tmp].size+1024, blockNum);
						int offsetOfPrg, segOfPrg;
						int offsetMask = 0x0000ffff;
						int segMask = 0xf0000;
						offsetOfPrg = memoryTable[blockNum].beginAddr & offsetMask;
						segOfPrg = (memoryTable[blockNum].beginAddr & segMask) >> 4;
						int cs = segOfPrg + (offsetOfPrg >> 4), ip = 0, ss = segOfPrg + (offsetOfPrg >> 4), sp = information[tmp].size+1024-1;
						createProcess(ProcessSize++, information[tmp].name, information[tmp].size+1024, cs, ip, ss, sp, blockNum);
						loadReal(information[tmp].lmaddress, information[tmp].size, offsetOfPrg, segOfPrg);
						enqueue(&ReadyQue, ProcessSize-1);
					}
				}
			}while(str[0] != '\0');
			runSub = 1;
			// wakeup();
			__asm__("int $0x8\n");
			runSub = 0;
			clear();
		}
		else if(in[0] == '.' && in[1] == '/')
		{
			tmp = find(in+2);
			if(tmp != -1 && information[tmp].deleted != 1){
				int blockNum = findEnoughBlock(information[tmp].size+1024);
				blockNum = require(information[tmp].size+1024, blockNum);
				int offsetOfPrg, segOfPrg;
				int offsetMask = 0x0000ffff;
				int segMask = 0xf0000;
				offsetOfPrg = memoryTable[blockNum].beginAddr & offsetMask;
				segOfPrg = (memoryTable[blockNum].beginAddr & segMask) >> 4;
				int cs = segOfPrg + (offsetOfPrg >> 4), ip = 0, ss = segOfPrg + (offsetOfPrg >> 4), sp = information[tmp].size+1024-1;
				createProcess(ProcessSize++, information[tmp].name, information[tmp].size+1024, cs, ip, ss, sp, blockNum);
				loadReal(information[tmp].lmaddress, information[tmp].size, offsetOfPrg, segOfPrg);
				enqueue(&ReadyQue, ProcessSize-1);
				runSub = 1;
				__asm__("int $0x8\n");
				runSub = 0;
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


