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
struct Queue SuspendQue;
struct semaphore semaphoreArray[SemaNum];
struct DelayQue delayQue;

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
	init(&SuspendQue);

	clear();
	char buffer[100];
	int status = fopen("manual.txt", readAndWriteFile);
	if (status == 400)
		printSentence("file down", 5, 0, 4, white);
	else {
		fread("manual.txt", buffer, 100);
		printSentence(buffer, 0, 0, strlen(buffer), white);
		fwrite("manual.txt", "12345678900987654321", 20);
		fread("manual.txt", buffer, 100);
		printSentence(buffer, 5, 0, strlen(buffer), white);
		fseek("manual.txt", 20);
		fread("manual.txt", buffer, 100);
		printSentence(buffer, 10, 0, strlen(buffer), white);
		fclose("manual.txt");
	}

	do {
		in = getInput();
		if (strcmp(in, "testFork") == 0) {
			tmp = find(in);
			int offsetOfPrg, segOfPrg;
			int offsetMask = 0x0000ffff;
			int segMask = 0xf0000;
			offsetOfPrg = 0x80000 & offsetMask;
			segOfPrg = (0x80000 & segMask) >> 4;
			int cs = segOfPrg + (offsetOfPrg >> 4), ip = 0, ss = segOfPrg + (offsetOfPrg >> 4), sp = information[tmp].size + 1024 - 1;
			createProcess(findNextProcessItem(), information[tmp].name, information[tmp].size + 1024, cs, ip, ss, sp, 9);
			ProcessSize += 1;
			enqueue(&ReadyQue, ProcessSize - 1);
			clear();
			runSub = 1;
			__asm__("int $0x8\n");
			runSub = 0;
			clear();
		}
		else if (in[0] == 'r' && in[1] == 'u' && in[2] == 'n')
		{
			printSentence("\n", line++, 0, strlen("\n"), white);
			do {
				str = getInput();
				printSentence("\n", line++, 0, strlen("\n"), white);
				if (str[0]) {
					tmp = find(str);
					if (tmp != -1 && information[tmp].deleted != 1) {
						int blockNum = findEnoughBlock(information[tmp].size + 1024);
						blockNum = require(information[tmp].size + 1024, blockNum);
						int offsetOfPrg, segOfPrg;
						int offsetMask = 0x0000ffff;
						int segMask = 0xf0000;
						offsetOfPrg = memoryTable[blockNum].beginAddr & offsetMask;
						segOfPrg = (memoryTable[blockNum].beginAddr & segMask) >> 4;
						int cs = segOfPrg + (offsetOfPrg >> 4), ip = 0, ss = segOfPrg + (offsetOfPrg >> 4), sp = information[tmp].size + 1024 - 1;
						createProcess(findNextProcessItem(), information[tmp].name, information[tmp].size + 1024, cs, ip, ss, sp, blockNum);
						ProcessSize += 1;
						loadReal(information[tmp].lmaddress, information[tmp].size, offsetOfPrg, segOfPrg);
						enqueue(&ReadyQue, ProcessSize - 1);
					}
				}
			} while (str[0] != '\0');
			int queSize = size(&BlockedQue);
			for (int i = 0; i < queSize; ++i)
			{
				dequeue(&BlockedQue, &tmp);
				if (processTable[tmp].waitProcess == -1) {
					processTable[tmp].status = ready;
					enqueue(&ReadyQue, tmp);
				} else {
					enqueue(&BlockedQue, tmp);
				}
			}
			runSub = 1;
			__asm__("int $0x8\n");
			runSub = 0;
			clear();
		}
		else if (in[0] == '.' && in[1] == '/')
		{
			tmp = find(in + 2);
			if (tmp != -1 && information[tmp].deleted != 1) {
				int blockNum = findEnoughBlock(information[tmp].size + 1024);
				blockNum = require(information[tmp].size + 1024, blockNum);
				int offsetOfPrg, segOfPrg;
				int offsetMask = 0x0000ffff;
				int segMask = 0xf0000;
				offsetOfPrg = memoryTable[blockNum].beginAddr & offsetMask;
				segOfPrg = (memoryTable[blockNum].beginAddr & segMask) >> 4;
				int cs = segOfPrg + (offsetOfPrg >> 4), ip = 0, ss = segOfPrg + (offsetOfPrg >> 4), sp = information[tmp].size + 1024 - 1;
				createProcess(findNextProcessItem(), information[tmp].name, information[tmp].size + 1024, cs, ip, ss, sp, blockNum);
				ProcessSize += 1;
				loadReal(information[tmp].lmaddress, information[tmp].size, offsetOfPrg, segOfPrg);
				enqueue(&ReadyQue, ProcessSize - 1);
				runSub = 1;
				__asm__("int $0x8\n");
				runSub = 0;
				clear();
			}
		}
		else if (in[0] == 't' && in[1] == 'y' &&
		         in[2] == 'p' && in[3] == 'e') {
			tmp = find(in + 5);
			if (tmp != -1 && information[tmp].deleted != 1) {
				fopen(in + 5, readAndWriteFile);
				char * contents = malloc(information[tmp].size);
				// fread(in + 5, contents, information[tmp].size);
				fread(in + 5, contents, information[tmp].size);
				// printSentence(contents, line, 0, information[tmp].size, white);
				printSentence(contents, line, 0, information[tmp].size, white);
				fclose(in + 5);
				line += countLines(contents);
			}
		}
		else if (in[0] == 'r' && in[1] == 'm') {
			tmp = find(in + 3);
			if (tmp != -1 && information[tmp].deleted != 1) {
				fdelete(in + 3);
			}
		}
		else if (in[0] == 'k' && in[1] == 'i' &&
		         in[2] == 'l' && in[3] == 'l') {
			kill(in[5] - '0');
		}
		else if (in[0] == 's' && in[1] == 'u' &&
		         in[2] == 's' && in[3] == 'p') {
			Tosuspend(in[5] - '0');
		}
		else if (in[0] == 'a' && in[1] == 'c' &&
		         in[2] == 't' && in[3] == 'i') {
			tmp = in[5] - '0';
			int blockNum = findEnoughBlock(processTable[tmp].size);
			blockNum = require(processTable[tmp].size, blockNum);
			processTable[tmp].blockNum = blockNum;
			int offsetOfPrg, segOfPrg;
			int offsetMask = 0x0000ffff;
			int segMask = 0xf0000;
			offsetOfPrg = memoryTable[blockNum].beginAddr & offsetMask;
			segOfPrg = (memoryTable[blockNum].beginAddr & segMask) >> 4;
			int cs = segOfPrg + (offsetOfPrg >> 4), ss = segOfPrg + (offsetOfPrg >> 4);
			processTable[tmp].pcb.cs = cs;
			processTable[tmp].pcb.ss_now = ss;
			activate(tmp);
		}
		else if (in[0] == 't' && in[1] == 'o' && in[2] == 'u' && in[3] == 'c' && in[4] == 'h')
		{
			fcreate(in + 6);
		}
		else if (in[0] == 'c' && in[1] == 'p')
		{
			int firstEnd;
			char sour[40], des[40];
			for (firstEnd = 3; in[firstEnd] != ' '; ++firstEnd) {}
			strncpy(in + 3, sour, firstEnd - 3);
			strncpy(in + firstEnd + 1, des, strlen(in) - firstEnd - 1);
			cp(sour, des);
		}
		else {
			if (strcmp(in, "reboot") == 0)
				reboot();
			if (strcmp(in, "clear") == 0)
				clear();
			if (strcmp(in, "date") == 0)
				date();
			if (strcmp(in, "man") == 0)
				man();
			if (strcmp(in, "ls") == 0)
				ls();
			if (strcmp(in, "exit") == 0)
				shutdown();
			if (strcmp(in, "ps") == 0)
				ps();
		}
		newline();
	} while (1);
	return 0;
}


