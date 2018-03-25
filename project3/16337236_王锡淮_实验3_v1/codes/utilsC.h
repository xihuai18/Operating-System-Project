#define Len 10

void initialScreen(int welcome);
int strlen(char * sen);
char* input();
int strcmp(char * l, char * r);
void man();
int countLines(char * sen);
void newline();
void date();
void strcpy(char * sour, char * des);
void ls();

enum fileType
{
	null=0, docu, exec, folder
};

struct info
{
	int lmaddress;
	int  size;
	char name[20];
	enum fileType type;
};

void initialFile();

int hashfun(char * key);

void hash(char * key, struct info record);

struct info find(char * key);

void int2str(int org, char * str);