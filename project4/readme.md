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

### Requirements Analysis
1. Clock Interruptions: 
    - [x] changing character '|', '\', '-'. '/'. 

2. Keybord Interruptions:
    - [x] showing "inserting" in the button when typing.
    - [x] showing "insert" when no input.

3. System Call
    - [ ] int 21h

4. Test Program
    - [ ]

5. File System
    - [x] File Allocate Table
    - [x] Contents Table

6. Remember to restore the interruptioin
    - [ ]