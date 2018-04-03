[BITS 16]
org 0x7c00
os equ 0x0500
offSetOfShow equ 0c200h
offSetOfNames equ 0c400h
offSetOfCheck equ 0c600h
offSetOfClear equ 0c800h
offSetOfManual equ 06000h
offSetOfRecord equ 07000h

[section .text]
load:
    sti
	mov ax, cs
	mov ds, ax
	mov es, ax

	call loadAll

	mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh,0                 ;磁头号 ; 起始编号为0
	mov ch,0                 ;柱面号 ; 起始编号为0
	mov bx, os ;偏移地址; 存放数据的内存偏移地址
    mov ah,2                 ; 功能号
    mov al,31                 ;扇区数
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



    call installInt2Bh

    call installInt9h

    call installInt8h

    int 8h

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
        pop ax ;IP ball_ifself

        jmp ax

installInt9h:
    xor ax, ax
    mov es, ax
    mov ax, cs
    mov ds, ax

    mov ax, word [es:9*4+2]
    mov [tmp+2], ax
    mov ax, word [es:9*4]
    mov [tmp], ax

    cli
    mov word [es:9*4+2], cs
    mov word [es:9*4], int9h
    sti

    ret


    tmp dw 0,0
int9h:
    pusha
    push es
    push ds

    mov ax, cs
    mov ds, ax

    pushf
    call far [tmp]


    mov ax, 0xb800
    mov es, ax
    mov ax, word [content]
    mov [es:(11*80+39)*2], ax

    inc word [content]

    mov al, 20h
    out 20h, al
    out 0A0h, al


    pop ds
    pop es
    popa

    iret
    content dw 0f30h

installInt8h:
    push es
    push ax
    xor ax, ax
    mov es, ax

    cli
    mov word [es:8*4+2], cs
    mov word [es:8*4], int8h
    mov word [count], delay
    sti

    pop ax
    pop es
    ret    
int8h:
    pusha
    push ds
    push es

    mov ax, cs
    mov ds, ax

    dec word [count]
    cmp word [count], 0
    jnz int8hret

    mov word [count], delay

    mov ax, 0xb800
    mov es, ax
    
    mov ah, 04h
    mov bh, 0
    mov ah, 3h
    int 10h
    ;此时dh，dl为行列位置
    
    mov ax, 0
    mov al, dh
    mov bl, 80
    mul bl
    mov dh, 0
    add ax, dx
    mov bx, 2
    mul bx
    mov bp, ax

    mov bx, char
    add bx, [k]
    mov al, [bx]
    mov ah, 0fh
    mov [es:bp], ax

    inc word [k]
    cmp word [k], 4
    jl int8hret
    mov word [k], 0

    int8hret:
    mov al, 20h
    out 20h, al
    out 0A0h, al
    pop es
    pop ds
    popa

    iret

    delay equ 4
    count dw delay
    k dw 0
    char db '|', '\', '-', '/'
times 510-($-$$) db 0
dw 0xaa55