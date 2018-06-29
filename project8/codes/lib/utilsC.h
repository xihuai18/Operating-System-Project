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

#define EXT2_NAME_LEN 118
#define EXT2_N_BLOCKS 15
#define EXT2_N_Catalog_Cache 15
#define EXT2_Block_Size 512

#define Len 20
#define MemLen 40
#define LenOfFat 200
#define SemaNum 60
#define Cluster 512
#define HeapLimit 5
#define FileOpenLimit 3


////////////////// Declarations ///////////////////////////////

////////////////// Declarations ends /////////////////////////


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


/////////////////////////////////  file system ////////////////////////////////

//////////////////////// EXT2 //////////////////////////
enum file_type
{
	unknown = 0, normal, catalog
};

struct group_desc;
struct inode;
struct catalog;

struct ext2_sup_op;
struct ext2_in_op;
struct super_node;


struct ext2_sup_op
{
	struct inode * (*alloc_inode)(struct super_node * sup);
	void (*destory_inode)(int inode, struct super_node * sup);
	int (*write_inode)(int inode, char * content, struct super_node * sup);
	char * (*read_inode)(int inode, struct super_node * sup);
};

struct ext2_in_op
{
	// change the catalog
	int (*create)(struct inode* ind, struct catalog* cat);
	int (*mkdir)(struct inode* ind, struct catalog* cat);
	int (*rmdir)(struct inode* ind, struct catalog* cat);
};

struct super_node
{
	int s_inodes_count; // 32 * 80 = 2560
	int s_blocks_count; // 2880
	int s_r_blocks_count; // 20
	int s_free_blocks_count;
	int s_free_inodes_count;
	int s_first_data_block; // 1 the first one is booting
	int s_log_block_size; // 9
	int s_first_ino; // 2: 0 for root content, 1 for kernel
	struct ext2_sup_op op;
};


struct group_desc
{
	int bg_block_bitmap;
	int bg_inode_bitmap;
	int bg_inode_table;
	int bg_free_blocks_count;
	int bg_free_inodes_count;
	int bg_used_dirs_count;
};

struct inode
{
	int i_mode;
	int i_uid;
	int i_size;
	int i_blocks;
	int i_flags;
	int i_block[EXT2_N_BLOCKS];
	struct ext2_in_op op;
};

struct catalog
{
	int inode;
	short rec_len;
	short name_len;
	short file_type;
	char name[EXT2_NAME_LEN];
};


struct catalogCache
{
	int hashTable[EXT2_N_Catalog_Cache];
	void (*EnCache)(char * key);
	int (*DeCache)(char * key);
};

// struct file_struct
// {
// 	int count;
// 	int file_lock;
// 	struct inode * open_file;
// };

struct file_struct
{
	char name[EXT2_NAME_LEN];
	int count; //引用计数
	int file_lock;
	int infoIndex;
	int memoryPlace;
	int seg;
	int memoryOffset;
	int size;
};

struct fs_struct
{
	int count;
	int lock;
	struct catalog * root;
	struct catalog * pwd;
};

struct BlockBufferUnit
{
	enum boolean dirty;
	int i_block;
	char block[EXT2_Block_Size];
};

struct BlockBuffer
{
	int tail, head, size;
	struct BlockBufferUnit array[Len];
};
void init2(struct BlockBuffer * que);
void enqueue2(struct BlockBuffer * que, int i_block);
struct BlockBufferUnit * dequeue2(struct BlockBuffer * que, int i_block);

///////////////////////// EXT2 ends ////////////////////////

//////////////////////// implementations ///////////////////
enum fileType
{
	null = 0, docu, exec, folder
};

struct info
{
	char name[30];
	enum fileType type;
	int lmaddress;
	int size;
	int deleted;
	int start;
	int blocks[MemLen];
};

int hashfun(char * key);

int hash(char * key, struct info record);

int find(char * key);

void loadFiles();

void setFAT(int lmaddress, int size);

void resetFAT(int lmaddress, int size);
//////////////////////// implementations end///////////////////


// /////////////////////// VFS /////////////////////////////
struct Superblock;
struct Dentry;
struct File;

struct super_operations
{
	struct IndexNode * (*alloc_inode)(struct Superblock * sup);
	void (*destory_inode)(int inode, struct Superblock * sup);
	int (*write_inode)(int inode, char * content, struct Superblock * sup);
	char * (*read_inode)(int inode, struct Superblock * sup);

};

struct inode_operations
{
	int (*create)(struct IndexNode* ind, struct Dentry* cat);
	int (*mkdir)(struct IndexNode* ind, struct Dentry* cat);
	int (*rmdir)(struct IndexNode* ind, struct Dentry* cat);
};

struct dentry_operations
{
	void (*d_delete)(struct Dentry * de);
};

struct file_operations
{
	int (*read)(struct File* f, char*buf, int count, int offset);
	int (*write)(struct File* f, char*buf, int count, int offset);
};

struct Superblock
{
	struct super_node * sup_b;
	struct super_operations sup_ops;
};

struct IndexNode
{
	// struct inode * i_nd;
	struct info * i_nd;
	struct inode_operations ind_ops;
};

struct Dentry
{
	struct inode * d_inode;
	struct Dentry * d_parent;
	char name[EXT2_NAME_LEN];
	struct dentry_operations d_ops;
};

struct File
{
	int offset;
	struct file_struct file;
	struct file_operations file_ops;
};



////////////////////////// VFS ends //////////////////////
enum openFileType
{
	readFile = 0, writeFile, appendFile, readAndWriteFile
};


void fcreate(char * name);
void fdelete(char * name);
int fopen(char * name, enum openFileType type);
int fclose(char * name);
int fseek(char *name, int offset);
int fread(char *name, char * buffer, int count);
int fwrite(char *name, char * buffer, int count);


int readReal(int seg, int memoryOffset, int size, int offset, char * buffer);

int writeReal(int seg, int memoryOffset, int size, int offset, char * buffer);

//////////////////////////////// file system ends ///////////////////////////////////////


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
	struct File openfile;
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

void cp(char * sour, char * des);
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