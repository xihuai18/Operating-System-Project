#define offsetOfManual 0x6000
#define offsetOfRecord 0x7000
#define offsetOfUserPrg 0xe000

void printSentence(char * message, int x, int y, int len, int color);
void ClearScreen();
char * getInput();
void shutdown();
void dispatch(int address);
void reboot();
void clear();
char * getDate();
void roll();
char * getRecords(int place);
void load(int lma, int size, int vma);