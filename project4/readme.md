# Experiment 4 & 5

### Traps Records

1. pushf before call the origin interruption.
2. the int 16h will change ds and so on in the process but restore them at last, so assign the segment registers and general registers in int 9h and save all the registers.
3. the IF and TF is originally set to 0(closed)
4. The outside interruptions need to tell the 8529A that the precedures are finished, while the soft interruptions needn't.
5. call far and call dword
6. 地址类型, c语言中会自动处理ds
7. ss,es,cs,ds要相同
8. 如何切换进程,要记录当前进程.
9. 如何分开save和dispatch
10. 考虑中断切换
11. load中断会改ax
12. cs好像不能直接改
13. push先減再放
14. C语言的变量在汇编中以地址形式。
15. 诡异事件，传名字错误，找到了，函数改了寄存器，，，
16. 汇编使用的C地址是16位的。
17. int21h 功能表
18. popa 注意返回值放在ax里面

### Requirements Analysis
1. Clock Interruptions: 
    - [x] changing character '|', '\', '-'. '/'. 

2. Keybord Interruptions:
    - [x] showing "inserting" in the button when typing.
    - [x] showing "insert" when no input.

3. System Call
    - [ ] int 21h
        + [X] ah = 00h 查看运行的进程
        + [X] ah = 01h 关闭进程
        + [X] ah = 02h 打印句子
        + [X] ah = 03h 显示时间
        + [X] ah = 04h 清空屏幕
        + [X] ah = 05h int类型转字符串
        + [X] ah = 4Ch 关闭操作系统

4. Test Program
    想法是显示现在是用的什么中断，再加一点特色。
    
    左上、右上、左下、右下。
    
    整个屏幕闪烁。

    - [X] 34h 
    - [X] 35h
    - [X] 36h
    - [X] 37h

5. File System
    - [x] File Allocate Table
    - [x] Contents Table

6. Process Control Block
    - [x] PCB
    - [X] Process Table