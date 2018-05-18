## Project 7

实验七遗留问题

- [X] ~~堆没有复制~~（尴尬，堆不用复制）
- [X] free函数
- [ ] 多级文件系统
- [X] 分次load
- [X] 换入不应该重启，merge写错了（~~就当我写了，~~我真的写了）
- [X] exit之后父进程取消子进程的进程表占用
    + 增加进程表功能，used什么的
- [X] malloc函数缺点：只找一次

实验八目标

+ 全部信号量应当在内核中保存，分配给进程。
+ 找RC问题，增大会发生RC问题的指令之间的间隔。
+ void delay(int clock)函数

信号量机制

+ 信号量：结构体，包含一个记录资源数目的整数和一个指向该信号量维护的队列的指针，以及记录该信号量是否被占用的布尔量；而内核维护这些信号量的方法是维护一个数组与和该数组大小相同的队列数组。
+ void do_p(int sem_id)原语，void p(int sem_id)函数调用，应该就是资源数减一后小于零就将当前进程阻塞（从ready队列拿出，放入指定阻塞队列），然后切换进程。
+ void do_v(int sem_id)原语，void v(int sem_id)函数调用，在资源数自增一后小于等于零就将队列头唤醒。
+ int do_getsem(int resourceSize)原语，int getsem(int resourceSize)函数，参数为资源数（信号量初始值），实现方法是寻找第一个没有被占用的信号量，初始化该信号量并返回其标号。
+ void do_freesem(int sem_id)原语，在c语言中用void freesem(int sem_id)调用，即释放占用的信号量。

void do_delay(int clock)原语和void delay(int clock)函数：

记录进程ID与对应的延时时钟数，将进程从ready队列取出，加入该阻塞队列（优先队列？），每次调用时钟中断便将延时时钟数减一，直至为0唤醒进程。
在内核中保存一个数据存放调用了delay的进程的ID，放在一个结构体中，该结构体包括一个ID和一个剩余delay数目。

void passOneClock()函数：

int 8h中调用

展示程序（实验报告详细写）：

- [ ] 理发师问题（我写的那个）。
- [X] 公平的读者写者问题。


### Traps

+ int21hTable
    woc!?
+ 全局变量不初始化 
+ readyQue
+ 我又取了局部变量的地址，3小时的代价，我就是个白痴。
+ 原语怎么调用进程切换
+ delay有毒，我拒绝
+ fork的新问题，绝望，又是你，千万不要用局部变量的地址。
