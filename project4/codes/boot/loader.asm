[BITS 16]
;segOfUser
org 0x7c00
offSetOfShow equ 0c200h
offSetOfNames equ 0c400h
offSetOfCheck equ 0c600h
offSetOfClear equ 0c800h
;segOfOs 
os equ 0x0000
offSetOfRecord equ 0d000h
offSetOfManual equ 0d500h
offSetOfFat equ 0e000h

segOfOs equ 0x2000 
segOfUser equ 0x0

[section .text]
load:
    sti
	mov ax, cs
	mov ds, ax
    mov ax, segOfOs
	mov es, ax

	call loadAll

    mov ax, segOfOs
    mov es, ax
	mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh,1                 ;磁头号 ; 起始编号为0
	mov ch,1                 ;柱面号 ; 起始编号为0
    mov bx, os ;偏移地址; 存放数据的内存偏移地址
    mov ah,2                 ; 功能号
    mov al,18                 ;扇区数
    mov cl,1                 ;起始扇区号 ; 起始编号为1
    int 13h ;                调用读磁盘BIOS的13h功能

    
    mov ah,2                 ; 功能号
    mov al,18                 ;扇区数
    mov dh,0                 ;磁头号 ; 起始编号为0
    mov ch,2                 ;柱面号 ; 起始编号为0
    add bx, 18*512 ;偏移地址; 存放数据的内存偏移地址
    int 13h

    mov ah,2                 ; 功能号
    mov al,18                 ;扇区数
    mov dh,1                 ;磁头号 ; 起始编号为0
    mov ch,2                 ;柱面号 ; 起始编号为0
    add bx, 18*512 ;偏移地址; 存放数据的内存偏移地址
    int 13h

    mov ah,2                 ; 功能号
    mov al,18                 ;扇区数
    mov dh,0                 ;磁头号 ; 起始编号为0
    mov ch,3                 ;柱面号 ; 起始编号为0
    add bx, 18*512 ;偏移地址; 存放数据的内存偏移地址
    int 13h

    mov ah,2                 ; 功能号
    mov al,18                 ;扇区数
    mov dh,1                 ;磁头号 ; 起始编号为0
    mov ch,3                 ;柱面号 ; 起始编号为0
    add bx, 18*512 ;偏移地址; 存放数据的内存偏移地址
    int 13h


    jmp segOfOs:os
    ; jmp $

loadAll:

    mov ax,segOfUser                ;段地址 ; 存放数据的内存基地址
    mov es,ax                ;设置段地址（不能直接mov es,段地址）
    mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,1                 ;磁头号 ; 起始编号为0
    ; mov dh,0                 ;磁头号 ; 起始编号为0
    mov ch,0                 ;柱面号 ; 起始编号为0
    ; mov ch,1                 ;柱面号 ; 起始编号为0


loadShow:
    mov bx,offSetOfShow  ;偏移地址; 存放数据的内存偏移地址
    mov ah,2                 ; 功能号
    mov al,1                 ;扇区数
    ; mov cl,19                 ;起始扇区号 ; 起始编号为1
    mov cl, 15                ;起始扇区号 ; 起始编号为1
    int 13H ;                调用读磁盘BIOS的13h功能

loadNames:
    mov bx,offSetOfNames  ;偏移地址; 存放数据的内存偏移地址
    mov ah,2                 ; 功能号
    mov al,1                 ;扇区数
    ; mov cl,20                 ;起始扇区号 ; 起始编号为1
    mov cl,16                 ;起始扇区号 ; 起始编号为1
    int 13H ;                调用读磁盘BIOS的13h功能


loadCheck:
    mov bx,offSetOfCheck  ;偏移地址; 存放数据的内存偏移地址
    mov ah,2                 ; 功能号
    mov al,1                 ;扇区数
    ; mov cl,21                 ;起始扇区号 ; 起始编号为1
    mov cl,17                 ;起始扇区号 ; 起始编号为1
    int 13H ;                调用读磁盘BIOS的13h功能

loadClear:
    mov bx,offSetOfClear  ;偏移地址; 存放数据的内存偏移地址
    mov ah,2                 ; 功能号
    mov al,1                 ;扇区数
    ; mov cl,22                ;起始扇区号 ; 起始编号为1
    mov cl,18                ;起始扇区号 ; 起始编号为1
    int 13H ;                调用读磁盘BIOS的13h功能

    mov ax,segOfOs                ;段地址 ; 存放数据的内存基地址
    mov es,ax                ;设置段地址（不能直接mov es,段地址）
    
loadManual:
    mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,0                 ;磁头号 ; 起始编号为0
    mov ch,1                 ;柱面号 ; 起始编号为0
    mov bx,offSetOfManual
    mov ah, 2
    mov al, 6
    mov cl, 13
    int 13h

loadRecord:
    mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,0                 ;磁头号 ; 起始编号为0
    mov ch,1                 ;柱面号 ; 起始编号为0
    mov bx,offSetOfRecord
    mov ah, 2
    mov al, 2
    mov cl, 11
    int 13h

loadFat:
    mov dl, 0
    mov dh, 0
    mov ch, 0
    mov bx, offSetOfFat
    mov ah, 2
    mov al, 12
    mov cl, 2
    int 13h

    ret ;loadAll



times 510-($-$$) db 0
dw 0xaa55