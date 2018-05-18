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

#define Len 20
#define MemLen 40
#define LenOfFat 200
#define SemaNum 60
#define Cluster 512
#define HeapLimit 5


///////////// utils /////////////////////
enum boolean
{
	fal = 0, tru
};

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
void delEle(struct Queue * que, int ele);
void clearQue(struct Queue * que);
////////////////////////////////////////


/////////  file system /////////////////
enum fileType
{
	null = 0, docu, exec, folder
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

void setFAT(int lmaddress, int size);

void resetFAT(int lmaddress, int size);
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
	Origin = 0, ready, running, blocked, suspend, exit
};

struct ListNode {
	int data;
	struct ListNode * next;
};

struct Process
{
	struct PCB pcb;
	int id; //id -1代表未被占用
	int blockNum;
	int lmaddress;
	int size;
	char name[30];
	int retValue; //退出时的返回值
	int fatherID;
	int waitProcess;
	int sonID;
	int heapArray[10];
	enum Processstatus status;
};

int findNextProcessItem();

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

void Tosuspend(int processID);

void activate(int processID);

struct DelayQue {
	struct Queue IDque;
	struct Queue clocksQue;
};

void do_delay(int clocks);

void passOneClock();

void processSwitch();
/////////////////////// process ends/////////////////////////////


/////////////// memory /////////////////////////////
void * malloc(int size);

void free(void * ptr, int ds);

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
	int used; // 该内存表项是否被使用
	enum memoryStatus status; // 该内存块的状态
};

int findEnoughBlock(int size);

int findLaterBlock(int addr, int size, int begin);

int require(int size, int blockNum);

int nextUnusedItem();

void loadFile(int lma, int size, int vma, int seg);

int findItem(int addr);
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

////////////////////// semaphore ///////////////////
struct semaphore
{
	int resources;
	enum boolean used;
	struct Queue semaQue;
};

void initSemaphore();

int do_getsem(int resourceSize);

void do_freesem(int sem_id);

void do_p(int sem_id);

void do_v(int sem_id);
////////////////////////////////////////////////////


#endif