#include "utilsC.h"
#define offsetOfManual 0xd500
#define offsetOfRecord 0xd000
#define offsetOfUserPrg 0xe000
#define offsetOfFat 0xe000
#define segOfOs 0x2000 
#define segOfUser 0x0

void printSentence(char * message, int x, int y, int len, int color);
void ClearScreen();
char * getInput();
void shutdown();
void dispatch(struct PCB * kernel, struct PCB * pro);
void reboot();
char * getDate();
void roll();
char * getRecords(int seg, int place);
void load(int lma, int size, int vma, int seg);
void test();