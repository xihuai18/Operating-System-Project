#define LEN 20
int fork();

void exitprg(int exit_value);

int wait();

void * malloc(int size);

void p(int sem_id);

void v(int sem_id);

int getsem(int resourceSize);

void freesem(int sem_id);

void delay(int clocks);

void free(void * ptr);

struct Queue
{
	int tail, head, size;
	int array[LEN];
};
int empty(struct Queue * que);
int size(struct Queue * que);
void init(struct Queue * que);
void enqueue(struct Queue * que, int ele);
void dequeue(struct Queue * que, int * ele);
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
	que->tail = LEN - 1;
	que->head = 0;
	que->size = 0;
}

void enqueue(struct Queue * que, int ele)
{
	if (que->size >= LEN)
		return ;
	que->size++;
	que->tail = (que->tail + 1) % LEN;
	que->array[que->tail] = ele;
}

void dequeue(struct Queue * que, int * ele)
{
	if (que->size <= 0)
		return ;
	que->size--;
	*ele = que->array[que->head];
	que->head = (que->head + 1) % LEN;
}