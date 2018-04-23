#include "utilsC.h"
#define offsetOfManual 0xd500
#define offsetOfRecord 0xd000
#define offsetOfUserPrg 0xe000
#define offsetOfFat 0xe000
#define segOfOs 0x2000 
#define segOfUser 0x0

//////////////// terminal(I/O) ///////////////////////////
void printSentence(char * message, int x, int y, int len, int color);

void ClearScreen();

char * getInput();

void shutdown();

void reboot();

char * getDate();

void roll();

char * getRecords(int seg, int place);
////////////// terminal ends ///////////////




///////////// process///////////////
// void dispatchReal(struct PCB * kernel, struct PCB * pro);

void loadReal(int lma, int size, int vma, int seg);

//////////////// process ends ///////



////////////// test /////////////////////
void test();
//////////////// test ends //////////////
