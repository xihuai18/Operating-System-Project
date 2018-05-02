// 提示符都是白色 0x0f
// 标签是绿色 0x0a
// 输入是黄色 0x0e
// 文本内容是紫色 0x0d
#ifndef __UTILS_H__
#define __UTILS_H__
#define white 0x0f
#define green 0x0a
#define yellow 0x0e
#define purple 0x0d
#define NULL 0

#define Len 50
#define MemLen 50
#define LenOfFat 200

/////////  filesystem /////////////////
enum fileType
{
	null=0, docu, exec, folder
};

struct info
{
	char name[30];
	enum fileType type;
	int lmaddress;
	int  size;
	int deleted;
	int start;
};

int hashfun(char * key);

int hash(char * key, struct info record);

int find(char * key);

void loadFiles();
/////////////////// file system ends ///////////////////


/////////////////// process ///////////////
struct PCB
{
	short gs;
	short fs;
	short es;
	short ds;
	short di;
	short si;
	short bp;
	short sp;
	short bx;
	short dx;
	short cx;
	short ax;
	// short retaddr; 

	short ip;
	short cs;
	short flags;
	short sp_now;
	short ss_now;
};

enum Processstatus
{
	Origin=0, ready, running, blocked, suspend, exit
};

struct Process
{
	struct PCB pcb;
	int id;
	int blockNum;
	char name[30];
	int retValue; //退出时的返回值
	int fatherID;
	int waitProcess;
	int sonID;
	enum Processstatus status;
};

void kill(int id);

// void createProcess(short cs, short ip, short ss, short sp, int id, char * name, int size, int fileId);
void createProcess(int id, char * name, int size, int cs, int ip, int ss, int sp, int blockNum);

// void dispatch(struct Process *oldPro, struct Process *newPro);

void schedule();

void block();

void wakeup();

void do_fork();

void do_exit(int exit_value);

int do_wait();

struct Queue
{
	int tail, head, size;
	int array[Len];
};

int empty(struct Queue * que);
int size(struct Queue * que);
void init(struct Queue * que);
void enqueue(struct Queue * que, int ele);
void dequeue(struct Queue * que, int * ele);
/////////////////////// process ends/////////////////////////////


/////////////// memory /////////////////////////////
void * malloc(int size);

enum memoryStatus
{
	unused = 0, used
};


struct MemoryBlock
{
	int beginAddr;
	int endAddr;
	int pre;
	int next;
	int used;
	enum memoryStatus status;
};

int findEnoughBlock(int size);

int findLaterBlock(int addr, int size);

int require(int size, int blockNum);

int nextUnusedItem();
//////////////////////memory ends///////////////////////////////

/////////// terminal(I/O) //////////////////////////////
char* input();

void clear();

void man();

int countLines(char * sen);

void newline();

void date();

void ls();

void ps();

void initial();
////////////////terminal ends//////////////////////////////////////


////////// string ////////////////////////////////////
int strlen(char * sen);

int strcmp(char * l, char * r);

void strncpy(char * sour, char * des, int len);

void int2str(int org, char * str);

void concate(char * sour, char * append);
/////////////////////////////////////////////////////


#endif