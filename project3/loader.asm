[BITS 16]
org 0x7c00
os equ 0x8100
offSetOfShow equ 0c200h
offSetOfNames equ 0c400h
offSetOfCheck equ 0c600h
offSetOfClear equ 0c800h
offSetOfManual equ 0ec00h

[section .text]
load:
	mov ax, cs
	mov ds, ax
	mov es, ax

	call loadAll

	mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh,0                 ;磁头号 ; 起始编号为0
	mov ch,0                 ;柱面号 ; 起始编号为0
	mov bx, os ;偏移地址; 存放数据的内存偏移地址
    mov ah,2                 ; 功能号
    mov al,17                 ;扇区数
    mov cl,2                 ;起始扇区号 ; 起始编号为1
    int 13h ;                调用读磁盘BIOS的13h功能

    jmp os

loadAll:

    mov ax,cs                ;段地址 ; 存放数据的内存基地址
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
    mov cl,1                 ;起始扇区号 ; 起始编号为1
    int 13H ;                调用读磁盘BIOS的13h功能

loadNames:
    mov bx,offSetOfNames  ;偏移地址; 存放数据的内存偏移地址
    mov ah,2                 ; 功能号
    mov al,1                 ;扇区数
    ; mov cl,20                 ;起始扇区号 ; 起始编号为1
    mov cl,2                 ;起始扇区号 ; 起始编号为1
    int 13H ;                调用读磁盘BIOS的13h功能


loadCheck:
    mov bx,offSetOfCheck  ;偏移地址; 存放数据的内存偏移地址
    mov ah,2                 ; 功能号
    mov al,1                 ;扇区数
    ; mov cl,21                 ;起始扇区号 ; 起始编号为1
    mov cl,3                 ;起始扇区号 ; 起始编号为1
    int 13H ;                调用读磁盘BIOS的13h功能

loadClear:
    mov bx,offSetOfClear  ;偏移地址; 存放数据的内存偏移地址
    mov ah,2                 ; 功能号
    mov al,1                 ;扇区数
    ; mov cl,22                ;起始扇区号 ; 起始编号为1
    mov cl,4                ;起始扇区号 ; 起始编号为1
    int 13H ;                调用读磁盘BIOS的13h功能

    
loadManual:
    mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,0                 ;磁头号 ; 起始编号为0
    mov ch,1                 ;柱面号 ; 起始编号为0
    mov bx,offSetOfManual
    mov ah, 2
    mov al, 2
    mov cl, 11
    int 13h

    call installInt2Bh
    ret ;loadAll


installInt2Bh:
    mov ax, 0
    mov es, ax
    mov word [es:2bh*4], int2Bh
    mov [es:2bh*4+2], cs
    ret
    int2Bh:
        popf
        pop ax ;CS
        pop ax ;IP

        pop ax ;IP checkinput
        pop ax ;IP dispatch

        jmp ax

times 510-($-$$) db 0
dw 0xaa55