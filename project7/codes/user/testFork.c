#define white 0x0f
#define NULL 0
#define TIMES1 20
#define TIMES2 5
__asm__(".code16gcc\n");
__asm__("mov %cs, %eax\n");
__asm__("mov %ax, %ds\n");
__asm__("mov %ax, %es\n");
__asm__("mov %ax, %ss\n");
__asm__("jmp __main\n");
#include "stdlib.h"
#include "stdio.h"
char str[200] = "Hello My Os!\r\nPress\r\n1) Deposite&Draw Problem              2) Reader&Writer Problem\r\n3) Barber Problem\r\n";
char tmpstr[20];
int line;


//// Reader&Writer
int competitorSem, bufferSem;
int readerCounter = 0;
int readerSem;
int buffer;

void reader(int pid) {
	for (int i = 0; i < TIMES2; ++i)
	{
		p(competitorSem);
		p(readerSem);
		++readerCounter;
		if (readerCounter == 1) {
			p(bufferSem);
		}
		v(readerSem);
		v(competitorSem);
		printSentence("reader: ", line, 0, 8, white);
		int2str(pid, tmpstr);
		printSentence(tmpstr, line, 8, strlen(tmpstr), white);
		printSentence("read: ", line, 9 + strlen(tmpstr), 6, white);
		int2str(buffer, tmpstr);
		printSentence(tmpstr, line++, 15 + strlen(tmpstr), strlen(tmpstr), white);
		p(readerSem);
		--readerCounter;
		if (readerCounter == 0) {
			v(bufferSem);
		}
		v(readerSem);
		// delay(1);
		__asm__("int $0x8\n");
	}
}

void writer() {
	for (int i = 0; i < TIMES2; ++i)
	{
		p(competitorSem);
		p(bufferSem);
		v(competitorSem);
		int tmp = i;
		int2str(i, tmpstr);
		printSentence("Write: ", line, 0, 7, white);
		printSentence(tmpstr, line++, 7, strlen(tmpstr), white);
		// delay(1);
		__asm__("int $0x8\n");
		buffer = tmp;
		v(bufferSem);
	}
}

// //////////////////////////////////////

// Barber
#define MAX_CAPACITY 10
#define SOFA_CAPACITY 4
#define BARBAR_NUM 3
int count = 0;
struct Queue queOne, queTwo;
int shopSem, sofaSem, barberChairSem, idleBarber, mutexCount, mutexQueOne, mutexQueTwo, custReadySem, payment;
int finished[MAX_CAPACITY], leaveChair[MAX_CAPACITY], receipt[MAX_CAPACITY];

void customer() {
	p(shopSem);
	p(mutexCount);
	++count;
	int custId = count;
	printSentence("Customer ", line, 0, strlen("Customer "), white);
	int2str(custId, tmpstr);
	printSentence(tmpstr, line, strlen("Customer "), strlen(tmpstr), white);
	printSentence(" coming", line++, strlen("Customer ") + strlen(tmpstr), strlen(" coming"), white);
	v(mutexCount);
	p(sofaSem);
	p(barberChairSem);
	v(sofaSem);
	p(mutexQueOne);
	enqueue(&queOne, custId);
	v(mutexQueOne);
	v(custReadySem);
	p(finished[custId]);
	v(leaveChair[custId]);
	p(mutexQueTwo);
	enqueue(&queTwo, custId);
	v(mutexQueTwo);
	v(payment);
	p(receipt[custId]);
	printSentence("Customer ", line, 0, strlen("Customer "), white);
	int2str(custId, tmpstr);
	printSentence(tmpstr, line, strlen("Customer "), strlen(tmpstr), white);
	printSentence(" leaving", line++, strlen("Customer ") + strlen(tmpstr), strlen(" leaving"), white);
	v(shopSem);
}

int pCust;
void casher() {
	while (1) {
		p(payment);
		p(mutexQueTwo);
		dequeue(&queTwo, &pCust);
		v(mutexQueTwo);
		p(idleBarber);
		printSentence("Customer ", line, 0, strlen("Customer "), white);
		int2str(pCust, tmpstr);
		printSentence(tmpstr, line, strlen("Customer "), strlen(tmpstr), white);
		printSentence(" payed", line++, strlen("Customer ") + strlen(tmpstr), strlen(" payed"), white);
		v(idleBarber);
		v(receipt[pCust]);
	}
}

int pCust;
void barber() {
	while (1) {
		p(custReadySem);
		p(mutexQueOne);
		dequeue(&queOne, &pCust);
		v(mutexQueOne);
		p(idleBarber);
		printSentence("Cutting hair: ", line, 0, strlen("Cutting hair: "), white);
		int2str(pCust, tmpstr);
		printSentence(tmpstr, line++, strlen("Cutting hair: "), strlen(tmpstr), white);
		v(idleBarber);
		v(finished[pCust]);
		p(leaveChair[pCust]);
		v(barberChairSem);
	}
}

///////////////////////////////////////////////

int Balance, totalDeposit, totalDraw;
int _main()
{
	line = 0;
	count = 0;
	printSentence(str, line++, 0, strlen(str), white);
	char ch = getchar();
	clear();
	line = 0;
	if (ch == '1') {
		Balance = 1000, totalDeposit = 0, totalDraw = 0;
		int semMemory = getsem(1);
		int pid = fork(), tmpBalance;
		if (pid) {
			for (int i = 0; i < TIMES1; ++i) {
				p(semMemory);
				tmpBalance = Balance;
				tmpBalance += 10;
				totalDeposit += 10;
				// delay(1);
				__asm__("int $0x8\n");
				Balance = tmpBalance;
				v(semMemory);
				int y = 0;
				printSentence("Balance: ", line, 0, strlen("Balance: "), white);
				y += strlen("Balance: ");
				int2str(tmpBalance, tmpstr);
				printSentence(tmpstr, line, y, strlen(tmpstr), white);
				y += strlen(tmpstr) + 1;
				printSentence("Deposited: ", line, y, strlen("Deposited: "), white);
				y += strlen("Deposited: ");
				int2str(totalDeposit, tmpstr);
				printSentence(tmpstr, line, y, strlen(tmpstr), white);
				y += strlen(tmpstr) + 1;
				printSentence("Drawed: ", line, y, strlen("Drawed: "), white);
				y += strlen("Drawed: ");
				int2str(totalDraw, tmpstr);
				printSentence(tmpstr, line, y, strlen(tmpstr), white);
				y += strlen(tmpstr);
				line++;
			}
		} else {
			for (int i = 0; i < TIMES1; ++i) {
				p(semMemory);
				Balance -= 20;
				totalDraw += 20;
				v(semMemory);
				// delay(1);
				__asm__("int $0x8\n");
			}
		}
	} else if (ch == '2') {
		// 3 readers and 1 writer
		competitorSem = getsem(1);
		bufferSem = getsem(1);
		readerSem = getsem(1);
		int pid = fork();
		if (pid) {
			writer();
		} else {
			pid = fork();
			if (pid) {
				reader(1);
			} else {
				pid = fork();
				if (pid) {
					reader(2);
				} else {
					reader(3);
				}
			}
		}
	} else {
		shopSem = getsem(MAX_CAPACITY), sofaSem = getsem(SOFA_CAPACITY), barberChairSem = getsem(BARBAR_NUM), idleBarber = getsem(BARBAR_NUM), mutexCount = getsem(1), mutexQueOne = getsem(1), mutexQueTwo = getsem(1), custReadySem =  getsem(0), payment = getsem(0);
		for (int i = 0; i < MAX_CAPACITY; ++i)
		{
			finished[i] = getsem(0);
			leaveChair[i] = getsem(0);
			receipt[i] = getsem(0);
		}
		init(&queOne);
		init(&queTwo);
		if (fork())
		{
			casher();
		} else if (fork()) {
			barber();
		} else if (fork()) {
			barber();
		} else if (fork()) {
			barber();
		} else if (fork()) {
			customer();
		} else {
			fork();
			fork();
			// fork();
			// fork();
			customer();
		}
	}
	getchar();
	exitprg(0);
}
