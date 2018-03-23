[BITS 16]
org 0x7c00
os equ 0x8100

[section .text]
load:
	mov ax, cs
	mov ds, ax
	mov es, ax

	mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh,0                 ;磁头号 ; 起始编号为0
	mov ch,0                 ;柱面号 ; 起始编号为0
	mov bx, os ;偏移地址; 存放数据的内存偏移地址
    mov ah,2                 ; 功能号
    mov al,20                 ;扇区数
    mov cl,2                 ;起始扇区号 ; 起始编号为1
    int 13h ;                调用读磁盘BIOS的13h功能

    jmp os

times 510-($-$$) db 0
dw 0xaa55