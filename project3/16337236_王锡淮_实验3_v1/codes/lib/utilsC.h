#define Len 100
// ;;;;;; 文件系统雏形 ;;;;;
// 首先需要一个全局的控制块，记录当前已用的位置和未用的位置。
// 然后需要一个目录项，记录文件名称、类型、删除标记、索引序号、兄弟、父文件夹。
// 索引节点，包括大小、地址。
enum fileType
{
	null=0, docu, exec, folder
};

// struct Control
// {
// 	int used;//第一个使用的位置
// 	int unused;//第一个未使用的位置
// };

// struct record
// {
// 	char name[30];
// 	enum fileType type;
// 	int deleted;
// 	int info_index;
// 	int father_folder;
// 	int sibling;
// 	int son;
// };

struct info
{
	char name[30];
	enum fileType type;
	int lmaddress;
	int  size;
	int deleted;
};

void initialFile();
void loadFiles();

void initialScreen(int welcome);
char* input();

int strlen(char * sen);
int strcmp(char * l, char * r);
void strncpy(char * sour, char * des, int len);

void man();
int countLines(char * sen);
void newline();
void date();
void ls();

int hashfun(char * key);

int hash(char * key, struct info record);

int find(char * key);

void int2str(int org, char * str);