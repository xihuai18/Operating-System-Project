#include "utilsC.h"
#include "utilsAsm.h"

#define max(x, y) \
	((x > y) ? x : y)

#define min(x, y) \
	((x > y) ? y : x)



extern struct info information[Len];
extern struct MemoryBlock memoryTable[Len];
extern struct info no;
extern int firstUnusedMemoryItem;
extern int line;
extern struct Control con;
extern struct record root;
extern short* FAT;
extern struct Process processTable[Len];
extern int curProcessId;
extern int ProcessSize;
extern int runSub;
extern struct Queue ReadyQue;
extern struct Queue BlockedQue;
extern struct Queue SuspendQue;
extern struct semaphore semaphoreArray[SemaNum];
extern struct DelayQue delayQue;

__asm__(".code16gcc\n");

char * WelcomeSentence = "oh my Wsh\n\rCopyright (C) Xihuai Wang\n\rtype \"man\" to get help\n\r";
char * prompt = ">>";

/////////// inside declarations /////////////
void release(int begin, int end);

void initialFile();

void initialMemoryTable();

void initialProcessTable();
/////////// inside declarations end ////////////

//////////// IO ////////////////////
int countLines(char * sen)
{
	int lines = 0;
	for (int i = 0; sen[i]; ++i) {
		if (sen[i] == '\n') {
			++lines;
		}
	}
	lines += 1;
	return lines;
}

void initialScreen(int welcome)
{
	clear();
	if (welcome) {
		printSentence(WelcomeSentence, line, 0, strlen(WelcomeSentence), white);
		line += countLines(WelcomeSentence);
	}
	printSentence(prompt, line, 0, strlen(prompt), white);
	line += countLines(prompt);
}

void clear()
{
	line = 0;
	ClearScreen();
}

void date()
{
	char * dateSen = getDate();
	printSentence(dateSen, line, 30, strlen(dateSen), purple);
	newline();
	line += countLines(dateSen);
}


void man()
{
	char * manual = getRecords(segOfOs, offsetOfManual);
	line = 0;
	ClearScreen();
	printSentence(manual, line, 0, strlen(manual), purple);
	line += countLines(manual);
}

void newline()
{
	if (line >= 25) {
		roll();
		line = 24;
	}
	printSentence(prompt, line, 0, strlen(prompt), white);
	line += countLines(prompt);
}

void ls()
{
	char * head = "Name           Size           Lma            Type";
	printSentence(head, line, 10, strlen(head), green);
	char typeTable[10][1] = {"N", "D", "E", "F"};
	line += countLines(head);
	char tmp[15];
	for (int i = 0; i < Len; ++i)
	{
		if (information[i].type != null && information[i].deleted != 1) {
			printSentence(information[i].name, line, 10, strlen(information[i].name), purple);
			if (information[i].size == 0) {
				printSentence("--", line, 25, 2, purple);
			} else {
				int2str(information[i].size, tmp);
				printSentence(tmp, line, 25, strlen(tmp), purple);
			}
			if (information[i].lmaddress == 0) {
				printSentence("--", line, 40, 2, purple);
			} else {
				int2str(information[i].lmaddress, tmp);
				printSentence(tmp, line, 40, strlen(tmp), purple);
			}
			printSentence(typeTable[information[i].type], line, 55, 1, purple);
			line += 1;
		}
	}
}

void ps()
{
	char * head = "Id  ProcessName       Status\n";
	char status[6][10] = {"Origin", "ready", "running", "blocked", "suspend", "exit"};
	int begin = 20;
	printSentence(head, line++, begin, strlen(head), purple);
	char str[30];
	for (int i = 0; i < Len; ++i)
	{
		if (processTable[i].id != -1 && processTable[i].status != Origin)
		{
			int2str(processTable[i].id, str);
			printSentence(str, line, begin + 1, strlen(str), purple);
			printSentence(processTable[i].name, line, begin + 5, strlen(processTable[i].name), purple);
			printSentence(status[processTable[i].status], line++, begin + 23, strlen(status[processTable[i].status]), purple);
		}
	}
}

void kill(int id)
{
	if (id != 0) {
		--ProcessSize;
		processTable[id].status = exit;
		processTable[id].id = -1;
		release(memoryTable[processTable[id].blockNum].beginAddr, memoryTable[processTable[id].blockNum].endAddr);
	}
}

void initial()
{
	initialFile();
	initialScreen(1);
	initialProcessTable();
	initialMemoryTable();
	initSemaphore();
}
///////////// IO ends ////////////////


//////////// string /////////////////
// ×¢Òâ×Ö·û´®ÒªÓÐ'0'½áÎ²¡£
int strlen(char * sen)
{
	int i = 0;
	while (sen[i]) { ++i; }
	return i;
}


void concate(char * sour, char * append)
{
	int lenOfAppend = strlen(append);
	int lenOfSour = strlen(sour);
	for (int i = 0; i < lenOfAppend; ++i)
	{
		sour[i + lenOfSour] = append[i];
	}
	sour[lenOfAppend + lenOfSour] = '\0';
}

int strcmp(char * l, char * r)
{
	int i = 0, j = 0;
	for (; l[i] && r[i]; ++i, ++j)
	{
		if (l[i] < r[j]) {
			return -1;
		} else if (l[i] > r[j]) {
			return 1;
		}
	}
	if (!l[i] && r[j]) {
		return -1;
	} else if (l[i] && !r[j]) {
		return 1;
	} else {
		return 0;
	}
}

void strncpy(char * sour, char * des, int len)
{
	int i = 0;
	while (sour[i] && i < len) {
		des[i] = sour[i];
		++i;
	}
	des[i] = '\0';
}

void int2str(int org, char * str)
{
	int num = 0;
	int cp = org;
	while (cp != 0)
	{
		cp /= 10;
		++num;
	}
	if (org == 0)
		num = 1;
	str[num--] = '\0';
	for (int i = num; i >= 0; --i)
	{
		str[i] = org % 10 + 48;
		org /= 10;
	}
}

////////////// string ends /////////////////


////////////// File ////////////////



int hashfun(char * key) {
	int weight = 29;
	int i = 0;
	int ret = 0;
	while (key[i]) {
		ret = (ret + key[i] * weight) % Len;
		++i;
	}
	return ret;
}

int hash(char * key, struct info record)
{
	int inicode = hashfun(key);
	int code = inicode, i = 1;
	while (information[code].type != null) {
		code = (inicode + i * i) % Len;
		++i;
	}


	information[code].type = record.type;
	strncpy(record.name, information[code].name, strlen(record.name));
	information[code].size = record.size;
	information[code].lmaddress = record.lmaddress;
	information[code].deleted = record.deleted;
	return code;
}

int find(char * key)
{
	int inicode = hashfun(key);
	int code = inicode, i = 1;
	while (information[code].type == null || strcmp(key, information[code].name) != 0) {
		code = (inicode + i * i) % Len;
		++i;
		if (i > Len)
			return -1;
	}
	return code;
}

void initialFile()
{
	FAT = (short*)getRecords(segOfOs, offsetOfFat);
	for (int i = 0; i < Len; ++i) {
		information[i].type = null;
	}
	no.lmaddress = 0;
	no.size = 0;
	no.type = null;
	strncpy("", no.name, 0);
	loadFiles();
}


void loadFiles()
{
	char * rawRecords = getRecords(segOfOs, offsetOfRecord);
	int i = 0;
	int l = 0;
	int size = 0;
	int place = 0;
	char name[30];
	enum fileType t = null;
	struct info tmp;
	while (rawRecords[i] != '\n')
	{
		size = 0;
		place = 0;
		// name
		++i;
		l = 0;
		while (rawRecords[i] != '|') {
			++i;
			++l;
		}
		++i;
		strncpy(rawRecords + i - l - 1, name, l);
		name[l] = '\0';
		// size
		while (rawRecords[i] != '|') {
			size = size * 10 + rawRecords[i] - '0';
			++i;
		}
		++i;
		// place
		while (rawRecords[i] != '|') {
			place = place * 10 + rawRecords[i] - '0';
			++i;
		}
		++i;
		//type
		t = rawRecords[i] - '0';
		i += 3;
		tmp.size = size;
		tmp.type = t;
		tmp.lmaddress = place;
		tmp.deleted = 0;
		tmp.start = place / Cluster;
		setFAT(place, size);
		strncpy(name, tmp.name, strlen(name));
		hash(name, tmp);
	}
}
// 注意FAT从0开始。
void setFAT(int lmaddress, int size)
{
	int begin = lmaddress / Cluster;
	int num = size / Cluster;
	for (int i = 0; i < num - 1; ++i)
	{
		FAT[i + begin] = i + begin + 1;
	}
	FAT[num + begin - 1] = 0xffff;
}

void resetFAT(int lmaddress, int size)
{
	int begin = lmaddress / Cluster;
	int num = size / Cluster;
	for (int i = 0; i < num; ++i)
	{
		FAT[i + begin] = 0;
	}
}

////////////// File ends ///////////////



///////////// process ////////////////
int findNextProcessItem()
{
	int id = -1;
	while (id == -1) {
		int tmpProcessID = (curProcessId + 1) % Len;
		if (processTable[tmpProcessID].id == -1) {
			id = tmpProcessID;
		}
	}
	return id;
}


void initialProcessTable()
{
	for (int i = 0; i < Len; ++i)
	{
		processTable[i].id = -1;
		processTable[i].status = Origin;
		processTable[i].fatherID = -1;
		processTable[i].sonID = -1;
		processTable[i].waitProcess = -1;
		for (int j = 0; j < HeapLimit; ++j)
		{
			processTable[i].heapArray[j] = -1;
		}

	}

	processTable[0].status = running;
	strncpy("kernel", processTable[0].name, 6);
	processTable[0].id = 0;
	processTable[0].pcb.cs = 0x2000;
	processTable[0].pcb.ip = 0x0;
	processTable[0].pcb.ss_now = 0x2000;
	processTable[0].pcb.sp_now = 0xffff;
	// curProcessId = 1;
}


//size要包括栈的大小
void createProcess(int id, char * name, int size, int cs, int ip, int ss, int sp, int blockNum)
{
	processTable[id].id = id;
	processTable[id].status = ready;
	// int blockNum = findEnoughBlock(size);
	// blockNum = require(size, blockNum);
	processTable[id].blockNum = blockNum;
	strncpy(name, processTable[id].name, strlen(name));
	// int offsetOfPrg, segOfPrg;
	// int offsetMask = 0x0000ffff;
	// int segMask = 0xf0000;
	// offsetOfPrg = memoryTable[blockNum].beginAddr & offsetMask;
	// segOfPrg = (memoryTable[blockNum].beginAddr & segMask) >> 4;

	//以下部分代码取巧，方法是直接改变cs和ss段（加上偏移量右移4位的值）以使得程序（org 0h）不需要org偏移量。
	// processTable[id].pcb.cs = segOfPrg + (offsetOfPrg >> 4);
	// processTable[id].pcb.ip = 0;
	// processTable[id].pcb.ss_now = segOfPrg + (offsetOfPrg >> 4);
	// processTable[id].pcb.sp_now = size-1;
	processTable[id].pcb.cs = cs;
	processTable[id].pcb.ip = ip;
	processTable[id].pcb.ss_now = ss;
	processTable[id].pcb.sp_now = sp;
	processTable[id].size = size;
	// loadReal(lmaddress, fileSize, offsetOfPrg, segOfPrg);
}

// 被内核阻塞的 waitProcess = -1
int quesize, tmp;
void block(int id)
{
	__asm__("cli\n");
	processTable[id].status = blocked;
	enqueue(&BlockedQue, id);
	quesize = size(&ReadyQue);
	for (int i = 0; i < quesize; ++i)
	{
		dequeue(&ReadyQue, &tmp);
		if (id != tmp)
			enqueue(&ReadyQue, tmp);
	}
	__asm__("sti\n");
}

void wakeup(int id)
{
	__asm__("cli\n");
	processTable[id].status = ready;
	enqueue(&ReadyQue, id);
	quesize = size(&BlockedQue);
	for (int i = 0; i < quesize; ++i)
	{
		dequeue(&BlockedQue, &tmp);
		if (id != tmp)
			enqueue(&BlockedQue, tmp);
	}
	__asm__("sti\n");
}

// 注意当前的状态，画出队列图？
// 当前状态可能是running或blocked
int next;
void schedule()
{
	int i = 0;
	if (runSub == 1 && size(&ReadyQue) > 1)
	{
		// 注意区分状态
		do {
			dequeue(&ReadyQue, &next);
			if (next == 0) {
				enqueue(&ReadyQue, next);
			}
		} while (next == 0);
		processTable[next].status = running;
		if (processTable[curProcessId].status == running) {
			processTable[curProcessId].status = ready;
			enqueue(&ReadyQue, curProcessId);
		}
		curProcessId = next;
	}
	else if (runSub == 1 && size(&ReadyQue) == 1)
	{
		// 从ring0到ring1，从ring1到ring0不同
		dequeue(&ReadyQue, &next);
		if (next != 0) {
			processTable[next].status = running;
			enqueue(&ReadyQue, curProcessId);
			curProcessId = next;
		} else if (processTable[curProcessId].status == running) {
			enqueue(&ReadyQue, next);
		} else {
			curProcessId = 0;
			processTable[curProcessId].status = running;
		}
	}
	else
	{
		curProcessId = 0;
		processTable[curProcessId].status = running;
	}
}


//记得关中断
//进来之前已经save自己，出去之后restart到另外的进程
char name[40];
void do_fork()
{
	int stackSize = 0x300;
	strncpy(processTable[curProcessId].name, name, strlen(processTable[curProcessId].name));
	concate(name, "Sub");
	int blockNum = findEnoughBlock(stackSize);
	blockNum = require(stackSize, blockNum);
	int segOfSour, segOfDes;
	int segMask = 0xf0000;
	int offsetMask = 0x0000ffff;
	segOfDes = (memoryTable[blockNum].beginAddr & segMask) >> 4;
	segOfSour = ((memoryTable[processTable[curProcessId].blockNum].endAddr - stackSize + 1) & segMask) >> 4;
	int cs = processTable[curProcessId].pcb.cs, ip = processTable[curProcessId].pcb.ip;
	int ss = segOfDes,
	    sp = ((memoryTable[blockNum].beginAddr)&offsetMask) + processTable[curProcessId].pcb.sp_now - ((memoryTable[processTable[curProcessId].blockNum].endAddr - stackSize + 1)&offsetMask);
	memcpy(segOfOs, (int)&processTable[curProcessId].pcb, segOfOs, (int)&processTable[ProcessSize].pcb, sizeof(struct PCB));
	memcpy(segOfSour, (memoryTable[processTable[curProcessId].blockNum].endAddr - stackSize + 1)&offsetMask, segOfDes, (memoryTable[blockNum].beginAddr)&offsetMask, stackSize);
	createProcess(ProcessSize++, name, stackSize, cs, ip, ss, sp, blockNum);
	enqueue(&ReadyQue, ProcessSize - 1);
	processTable[ProcessSize - 1].fatherID = curProcessId;
	processTable[curProcessId].sonID = ProcessSize - 1;
	processTable[curProcessId].pcb.ax = ProcessSize - 1;
	processTable[ProcessSize - 1].pcb.ax = 0;
}

void do_exit(int exit_value)
{
	quesize	= size(&BlockedQue);
	for (int i = 0; i < quesize; ++i)
	{
		dequeue(&BlockedQue, &tmp);
		if (processTable[tmp].waitProcess == curProcessId)
		{
			wakeup(tmp);
		}
		else {
			block(tmp);
		}
	}
	processTable[curProcessId].retValue = exit_value;
	kill(curProcessId);
	processSwitch();
}

int do_wait()
{
	processTable[curProcessId].waitProcess = processTable[curProcessId].sonID;
	block(curProcessId);
	processSwitch();
	int ret = processTable[processTable[curProcessId].sonID].retValue;
	processTable[curProcessId].sonID = -1;
	return ret;
}

void Tosuspend(int processID)
{
	int Size = memoryTable[processTable[processID].blockNum].endAddr - memoryTable[processTable[processID].blockNum].beginAddr + 1;
	int count = 0;
	int begin = 0;
	for (int i = 0; i < LenOfFat; ++i)
	{
		if (FAT[begin] == 0)
		{
			++count;
		}
		else {
			begin = i + 1;
			count = 0;
		}
		if (count * Cluster >= Size)
		{
			break;
		}
	}
	write(begin * Cluster, Size, (memoryTable[processTable[processID].blockNum].beginAddr & 0x0000ffff), (memoryTable[processTable[processID].blockNum].beginAddr & 0xf0000) >> 4);
	processTable[processID].lmaddress = begin * Cluster;
	enqueue(&SuspendQue, processID);
	///////////////////////////
	if (processTable[processID].status == ready)
		////////////////////////////
	{
		quesize = size(&ReadyQue);
		for (int i = 0; i < quesize; ++i)
		{
			dequeue(&ReadyQue, &tmp);
			if (tmp != processID)
			{
				enqueue(&ReadyQue, tmp);
			}
		}
	}
	///////////////////////////
	else if (processTable[processID].status == blocked)
		////////////////////////////
	{
		quesize = size(&BlockedQue);
		for (int i = 0; i < quesize; ++i)
		{
			dequeue(&BlockedQue, &tmp);
			if (tmp != processID)
			{
				enqueue(&BlockedQue, tmp);
			}
		}
	}
	// ip和sp为相对位移，重启不改动
	processTable[processID].status = suspend;
	release(memoryTable[processTable[processID].blockNum].beginAddr, memoryTable[processTable[processID].blockNum].endAddr);
}
void activate(int processID)
{
	loadFile(processTable[processID].lmaddress, processTable[processID].size, (memoryTable[processTable[processID].blockNum].beginAddr & 0x0000ffff), (memoryTable[processTable[processID].blockNum].beginAddr & 0xf0000) >> 4);
	quesize = size(&SuspendQue);
	for (int i = 0; i < quesize; ++i)
	{
		dequeue(&SuspendQue, &tmp);
		if (tmp != processID)
		{
			enqueue(&SuspendQue, tmp);
		}
	}
	processTable[processID].status = ready;
	enqueue(&ReadyQue, processID);
}

void do_delay(int clocks)
{
	delEle(&ReadyQue, curProcessId);
	processTable[curProcessId].status = blocked;
	enqueue(&BlockedQue, curProcessId);
	enqueue(&(delayQue.IDque), curProcessId);
	enqueue(&(delayQue.clocksQue), clocks);
	processSwitch();
}

int tmpID;
int tmpClocks;
void passOneClock()
{
	int queSize = size(&(delayQue.IDque));
	for (int i = 0; i < queSize; ++i)
	{
		dequeue(&(delayQue.IDque), &tmpID);
		dequeue(&(delayQue.clocksQue), &tmpClocks);
		tmpClocks -= 1;
		if (tmpClocks <= 0) {
			delEle(&BlockedQue, tmpID);
			processTable[tmpID].status = ready;
			enqueue(&ReadyQue, tmpID);
		} else {
			enqueue(&(delayQue.IDque), tmpID);
			enqueue(&(delayQue.clocksQue), tmpClocks);
		}
	}
}

void processSwitch()
{
	__asm__("sti\n");
	__asm__("int $0x8\n");
	__asm__("cli\n");
}
///////////// process ends //////////


//////////// memory /////////////
void * malloc(int size)
{
	int ds;
	__asm__("mov %gs, %eax\n");
	__asm__("pushl %eax");
	__asm__("popl %0":"=m"(ds));
	//ds现在是gs(ds)寄存器的值。
	char tmpstr[10];
	// int2str(ds, tmpstr);
	// printSentence(tmpstr, 12, 0, 5, white);
	size = size + (16 - size % 16);
	int begin = 0;
	for (int j = 0; j < MemLen; ++j) {
		int blockNum = findLaterBlock(ds << 4, size, begin);
		int endDs = ((memoryTable[blockNum].beginAddr + size) & 0xf0000) >> 4;
		if (endDs <= ds) {
			blockNum = require(size, blockNum);
			int i = 0;
			for (; i < HeapLimit; ++i)
			{
				if (processTable[curProcessId].heapArray[i] == -1) {
					processTable[curProcessId].heapArray[i] = blockNum;
					break;
				}
			}
			return (void*)((memoryTable[blockNum].beginAddr) - (ds << 4));
		} else {
			begin = blockNum;
		}
	}
	return NULL;
}

void free(void * ptr, int ds)
{
	int item = findItem((int)ptr + (ds << 4));
	if (item != -1) {
		release(memoryTable[item].beginAddr, memoryTable[item].endAddr);
	}
}

int nextUnusedItem()
{
	for (int i = 0; i < MemLen; ++i)
	{
		if (memoryTable[i].used == 0)
			return i;
	}
	return -1;
}

void initialMemoryTable()
{
	int next;
	for (int i = 0; i < MemLen; ++i)
	{
		memoryTable[i].used = 0;
		memoryTable[i].next = -1;
		memoryTable[i].pre = -1;
		memoryTable[i].status = unused;
	}
	firstUnusedMemoryItem = 0;
	memoryTable[firstUnusedMemoryItem].pre = -1;
	memoryTable[firstUnusedMemoryItem].used = 1;
	memoryTable[firstUnusedMemoryItem].beginAddr = 0;
	memoryTable[firstUnusedMemoryItem].endAddr = 0x4ff;
	memoryTable[firstUnusedMemoryItem].status = used;
	next = nextUnusedItem();
	memoryTable[next].pre = firstUnusedMemoryItem;
	memoryTable[firstUnusedMemoryItem].next = next;
	firstUnusedMemoryItem = next;

	memoryTable[firstUnusedMemoryItem].used = 1;
	memoryTable[firstUnusedMemoryItem].beginAddr = 0x500;
	memoryTable[firstUnusedMemoryItem].endAddr = 0x7cff;
	memoryTable[firstUnusedMemoryItem].status = unused;
	next = nextUnusedItem();
	memoryTable[next].pre = firstUnusedMemoryItem;
	memoryTable[firstUnusedMemoryItem].next = next;
	firstUnusedMemoryItem = next;


	memoryTable[firstUnusedMemoryItem].used = 1;
	memoryTable[firstUnusedMemoryItem].beginAddr = 0x7e00;
	memoryTable[firstUnusedMemoryItem].endAddr = 0x7dff;
	memoryTable[firstUnusedMemoryItem].status = used;
	next = nextUnusedItem();
	memoryTable[next].pre = firstUnusedMemoryItem;
	memoryTable[firstUnusedMemoryItem].next = next;
	firstUnusedMemoryItem = next;

	memoryTable[firstUnusedMemoryItem].used = 1;
	memoryTable[firstUnusedMemoryItem].beginAddr = 0x7e00;
	memoryTable[firstUnusedMemoryItem].endAddr = 0xc1ff;
	memoryTable[firstUnusedMemoryItem].status = unused;
	next = nextUnusedItem();
	memoryTable[next].pre = firstUnusedMemoryItem;
	memoryTable[firstUnusedMemoryItem].next = next;
	firstUnusedMemoryItem = next;

	memoryTable[firstUnusedMemoryItem].used = 1;
	memoryTable[firstUnusedMemoryItem].beginAddr = 0xc200;
	memoryTable[firstUnusedMemoryItem].endAddr = 0xc9ff;
	memoryTable[firstUnusedMemoryItem].status = used;
	next = nextUnusedItem();
	memoryTable[next].pre = firstUnusedMemoryItem;
	memoryTable[firstUnusedMemoryItem].next = next;
	firstUnusedMemoryItem = next;

	memoryTable[firstUnusedMemoryItem].used = 1;
	memoryTable[firstUnusedMemoryItem].beginAddr = 0xca00;
	memoryTable[firstUnusedMemoryItem].endAddr = 0x1ffff;
	memoryTable[firstUnusedMemoryItem].status = unused;
	next = nextUnusedItem();
	memoryTable[next].pre = firstUnusedMemoryItem;
	memoryTable[firstUnusedMemoryItem].next = next;
	firstUnusedMemoryItem = next;

	memoryTable[firstUnusedMemoryItem].used = 1;
	memoryTable[firstUnusedMemoryItem].beginAddr = 0x20000;
	memoryTable[firstUnusedMemoryItem].endAddr = 0x2cfff;
	memoryTable[firstUnusedMemoryItem].status = used;
	next = nextUnusedItem();
	memoryTable[next].pre = firstUnusedMemoryItem;
	memoryTable[firstUnusedMemoryItem].next = next;
	firstUnusedMemoryItem = next;
	// blockNum = 7;
	memoryTable[firstUnusedMemoryItem].used = 1;
	memoryTable[firstUnusedMemoryItem].beginAddr = 0x2d000;
	memoryTable[firstUnusedMemoryItem].endAddr = 0x2ffff;
	memoryTable[firstUnusedMemoryItem].status = used;
	next = nextUnusedItem();
	memoryTable[next].pre = firstUnusedMemoryItem;
	memoryTable[firstUnusedMemoryItem].next = next;
	firstUnusedMemoryItem = next;

	// blockNum = 8;
	memoryTable[firstUnusedMemoryItem].used = 1;
	memoryTable[firstUnusedMemoryItem].beginAddr = 0x30000;
	memoryTable[firstUnusedMemoryItem].endAddr = 0x7ffff;
	memoryTable[firstUnusedMemoryItem].status = unused;
	next = nextUnusedItem();
	memoryTable[next].pre = firstUnusedMemoryItem;
	memoryTable[firstUnusedMemoryItem].next = next;
	firstUnusedMemoryItem = next;

	// blockNum = 9;
	memoryTable[firstUnusedMemoryItem].used = 1;
	memoryTable[firstUnusedMemoryItem].beginAddr = 0x80000;
	memoryTable[firstUnusedMemoryItem].endAddr = 0x86fff;
	memoryTable[firstUnusedMemoryItem].status = used;
	next = nextUnusedItem();
	memoryTable[next].pre = firstUnusedMemoryItem;
	memoryTable[firstUnusedMemoryItem].next = next;
	firstUnusedMemoryItem = next;

	// blockNum = 10;
	memoryTable[firstUnusedMemoryItem].used = 1;
	memoryTable[firstUnusedMemoryItem].beginAddr = 0x87000;
	memoryTable[firstUnusedMemoryItem].endAddr = 0x9ffff;
	memoryTable[firstUnusedMemoryItem].status = unused;
	next = nextUnusedItem();
	memoryTable[next].pre = firstUnusedMemoryItem;
	memoryTable[firstUnusedMemoryItem].next = next;
	firstUnusedMemoryItem = next;
}


int findItem(int addr)
{
	int itemId = 0;
	for (; itemId < MemLen; itemId = memoryTable[itemId].next)
	{
		if (memoryTable[itemId].beginAddr == addr)
			return itemId;
	}
	return -1;
}

int findLaterBlock(int addr, int size, int begin)
{
	int itemId = begin;
	for (; itemId < MemLen; itemId = memoryTable[itemId].next)
	{
		if (memoryTable[itemId].beginAddr >= addr && memoryTable[itemId].endAddr - memoryTable[itemId].beginAddr + 1 >= size && memoryTable[itemId].status == unused)
			return itemId;
	}
	return -1;
}

void merge(int item)
{
	int first;
	if (memoryTable[item].pre != -1 && memoryTable[memoryTable[item].pre].status == unused) {
		first = memoryTable[item].pre;
	} else {
		first = item;
	}
	int next = memoryTable[first].next;
	while (next != -1 && memoryTable[next].status == unused)
	{
		memoryTable[first].endAddr = memoryTable[next].endAddr;
		memoryTable[first].next = memoryTable[next].next;
		if (memoryTable[next].next != -1) {
			memoryTable[memoryTable[next].next].pre = first;
		}
		memoryTable[next].used = 0;
		next = memoryTable[first].next;
	}

}

void release(int begin, int end)
{
	int item = findItem(begin);
	memoryTable[item].status = unused;
	merge(item);
}

int findEnoughBlock(int size)
{
	int itemId = 0;
	// 不考虑退化情况
	while (memoryTable[itemId].status == used || memoryTable[itemId].endAddr - memoryTable[itemId].beginAddr + 1 < size)
	{
		itemId = memoryTable[itemId].next;
	}
	return itemId;
}


int require(int size, int curId)
{
	memoryTable[firstUnusedMemoryItem].beginAddr = memoryTable[curId].beginAddr;
	memoryTable[firstUnusedMemoryItem].endAddr = memoryTable[firstUnusedMemoryItem].beginAddr + size - 1;
	memoryTable[firstUnusedMemoryItem].used = 1;
	memoryTable[firstUnusedMemoryItem].status = used;
	memoryTable[firstUnusedMemoryItem].pre = memoryTable[curId].pre;
	memoryTable[firstUnusedMemoryItem].next = curId;
	memoryTable[memoryTable[curId].pre].next = firstUnusedMemoryItem;
	memoryTable[curId].pre = firstUnusedMemoryItem;
	memoryTable[curId].beginAddr = memoryTable[firstUnusedMemoryItem].endAddr + 1;
	if (memoryTable[curId].beginAddr >= memoryTable[curId].endAddr)
	{
		memoryTable[firstUnusedMemoryItem].next = memoryTable[curId].next;
		memoryTable[curId].used = 0;
	}
	int ret = firstUnusedMemoryItem;
	firstUnusedMemoryItem = nextUnusedItem();
	return ret;
}

void loadFile(int lma, int size, int vma, int seg)
{
	int tmpSize = size;
	int loadtimes = 0;
	do {
		loadReal(lma + loadtimes * 18 * 512, min(tmpSize, 18 * 512), vma + loadtimes * 18 * 512, seg);
		loadtimes += 1;
		tmpSize -= 18 * 512;
	} while (tmpSize >= 18 * 512);
}

/////////// memory ends /////////////

////////// semaphore ////////////////
void initSemaphore()
{
	for (int i = 0; i < SemaNum; ++i)
	{
		semaphoreArray[i].used = fal;
		init(&semaphoreArray[i].semaQue);
	}
}

int do_getsem(int resourceSize)
{
	int i = 0;
	while (semaphoreArray[i].used == tru) { ++i; }
	if (i >= SemaNum)
		return -1;
	semaphoreArray[i].used = tru;
	semaphoreArray[i].resources = resourceSize;
	return i;
}

void do_freesem(int sem_id)
{
	semaphoreArray[sem_id].used = fal;
	clearQue(&semaphoreArray[sem_id].semaQue);
}

void do_p(int sem_id)
{
	__asm__("cli\n");
	semaphoreArray[sem_id].resources -= 1;
	if (semaphoreArray[sem_id].resources < 0)
	{
		delEle(&ReadyQue, curProcessId);
		processTable[curProcessId].status = blocked;
		enqueue(&semaphoreArray[sem_id].semaQue, curProcessId);
		processSwitch();
	}
	__asm__("sti\n");
}


void do_v(int sem_id)
{
	__asm__("cli\n");
	++semaphoreArray[sem_id].resources;
	if (semaphoreArray[sem_id].resources <= 0)
	{
		dequeue(&semaphoreArray[sem_id].semaQue, &tmpID);
		processTable[tmpID].status = ready;
		enqueue(&ReadyQue, tmpID);
	}
	__asm__("sti\n");
}
/////////////////////////////////////


////////////// utils /////////////////
int empty(struct Queue * que)
{
	return que->size == 0;
}

int size(struct Queue * que)
{
	return que->size;
}

void init(struct Queue * que)
{
	que->tail = Len - 1;
	que->head = 0;
	que->size = 0;
}

void enqueue(struct Queue * que, int ele)
{
	if (que->size >= Len)
		return ;
	que->size++;
	que->tail = (que->tail + 1) % Len;
	que->array[que->tail] = ele;
}

void dequeue(struct Queue * que, int * ele)
{
	if (que->size <= 0)
		return ;
	que->size--;
	*ele = que->array[que->head];
	que->head = (que->head + 1) % Len;
}

void clearQue(struct Queue * que)
{
	for (int i = 0; i < Len; ++i)
	{
		que->array[i] = 0;
	}
	init(que);
}

void delEle(struct Queue * que, int ele)
{
	int queSize = size(que);
	for (int i = 0; i < queSize; ++i)
	{
		dequeue(que, &tmp);
		if (tmp != ele)
		{
			enqueue(que, tmp);
		}
	}
}
/////////////////////////////////////


////////// interruptions //////////
void int34h()
{
	char * s = "Int 34h Xihuai Wang";
	printSentence(s, 6, 5, strlen(s), purple);
}
void int35h()
{
	char * s = "Int 35h 16337236";
	printSentence(s, 6, 46, strlen(s), purple);
}
void int36h()
{
	char * s = "Int 34h Class two";
	printSentence(s, 18, 5, strlen(s), purple);
}
void int37h()
{
	char * s = "Int 34h Grade 2016";
	printSentence(s, 18, 46, strlen(s), purple);
}

////////// interruptions  end//////////

