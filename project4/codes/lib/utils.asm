[BITS 16]

global _printSentence
global _ClearScreen
global _getInput
global _shutdown
global _dispatch
global _reboot
global _getManual
global _getDate
global _roll
global _getRecords
global _load
global _inisys
extern _curId

[section .text]
segOfOs equ 0x2000 
segOfUser equ 0x0
_inisys:
	
	call installInt8h
	call installInt9h
	call installInt2Bh

	ret

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
        retf ;IP ball_ifself

installInt9h:
    xor ax, ax
    mov es, ax
    mov ax, cs
    mov ds, ax

    mov ax, word [es:9*4+2]
    mov [tmp9+2], ax
    mov ax, word [es:9*4]
    mov [tmp9], ax

    cli
    mov word [es:9*4+2], cs
    mov word [es:9*4], int9h
    sti

    ret


    tmp9 dw 0,0
int9h:
    pusha
    push es
    push ds

    mov ax, cs
    mov ds, ax
    mov es, ax
   
    pushf
    call far [tmp9]
   
showInsert:
    mov cx, inserting_len
    mov bp, inserting
    mov dx, 0x1845
    mov bl, 0fh
    mov bh, 0
    mov ah, 13h
    mov al, 0
    int 10h

    mov al, 20h
    out 20h, al
    out 0A0h, al


    pop ds
    pop es
    popa

    iret

    inserting db "inserting"
    inserting_len equ $-inserting

installInt8h:
    push es
    push ax
    xor ax, ax
    mov es, ax

    mov ax, word [es:8*4+2]
    mov [tmp8+2], ax
    mov ax, word [es:8*4]
    mov [tmp8], ax

    cli
    mov word [es:8*4+2], cs
    mov word [es:8*4], int8h
    mov word [count], delay
    sti

    pop ax
    pop es
    ret    

    tmp8 dw 0, 0
int8h:
    pusha
    push ds
    push es

    mov ax, cs
    mov ds, ax

    pushf
    call far [tmp8]

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
    mov ax, 0x0f20
    mov [es:bp+2], ax
    mov [es:bp+4], ax
    mov [es:bp+6], ax
    mov [es:bp+8], ax

    inc word [k]
    cmp word [k], 4
    jl insertShow
    mov word [k], 0

insertShow:
	push es
	mov ax, cs
	mov es, ax
	mov cx, inserted_len
	mov bp, inserted
    mov dx, 0x1845
    mov bl, 0fh
    mov bh, 0
    mov ah, 13h
    mov al, 0
    int 10h
    pop es

int8hret:
    mov al, 20h
    out 20h, al
    out 0A0h, al
    pop es
    pop ds
    popa

    iret

    delay equ 40
    count dw delay
    k dw 0
    char db '|', '\', '-', '/'
    inserted db "inserted "
    inserted_len equ $-inserted

_printSentence:
	;;; _printSentence(message, dh, dl, len, color) ;;;;;
	push ebp
	mov ax, cs
	mov ds, ax
	mov es, ax
 	
 	mov bl, byte [esp+18h]
 	mov cx, word [esp+14h]
 	mov dl, byte [esp+10h]; 列
 	mov dh, byte [esp+0ch]; 行
 	mov bp, word [esp+08h]
	mov al,1
    mov bh,0
    ; mov bl,0fh          ;白底黑字
    push cs
    pop es
    mov ah,13h
    int 10h

    pop ebp
	pop ecx
	jmp cx
	
_ClearScreen:
	;;; _ClearScreen() ;;;;
	mov ah, 06h
	mov al, 0 ; 0 是清空屏幕
	mov bh, 0fh; 白底黑字
	mov ch, 0
	mov cl, 0
	mov dh, 24
	mov dl, 79
	int 10h

	pop ecx

	jmp cx

_getInput:
	;;; char * _getInput() ;;;
	;;; 功能是从键盘读取输入，支持删除，回显，回车表示输入完毕 ;;;
	; 读取输入
	; 		-是否为删除
	; 					是-退栈，显示字符，注意向屏幕输出空格覆盖
	; 		-是否为回车
	; 					是-字符串末尾补'0'，返回字符串地址到eax中
						
	; 		-是否为普通字符		
	; 					是-入栈，显示字符
	; 最大长度为100
	mov word [top], 0
	getStr:
	mov ah, 0
	int 16h
	cmp al, 20h
	jl nochar
	mov ah, 0
	call charstart
	jmp getStr

	nochar:
	cmp ah, 0eh ;退格键的扫描码
	je backspace
	cmp ah, 1ch ;enter键的扫描码
	je enter
	jmp getStr

	backspace:
	mov ah, 1
	call charstart
	jmp getStr

	enter:
	mov al, 0
	mov ah, 0
	call charstart

	sub eax, eax
	mov ax, input

	pop ecx

	jmp cx
	Charmini: 
	;子程序，ah为功能号，
	; 0为字符入栈，此时al为字符
	; 1为出栈，al为返回的字符
	; 二者都改变回显
	charstart:
		push bx
		push dx
		push di
		push es

		cmp ah, 1
		jg Charminiret
		mov bl, ah
		mov bh, 0
		add bx, bx
		jmp word [getInputTable+bx]
	; 注意top所在字节不是需要的内容。
	charpush:
		cmp byte [top], 100
		jge Charminiret
		mov bx, [top]
		inc byte [top]
		mov byte [input+bx], al
		call charshow
		jmp Charminiret

	charpop:
		cmp byte [top], 0
		jle Charminiret
		dec byte [top]
		mov bx, [top]
		mov al, [input+bx]
		call coverLast
		jmp Charminiret
	; 中断int 10h/13h显示字符串
	charshow: 
		push ebp
		mov bh, 0
		mov ah, 3h
		int 10h
		;此时dh，dl为行列位置
		mov al, 1h ; 光标位置改变
		mov ah, 13h
		mov bh, 0
		mov bl, 0eh ;黑底白字
		mov cx, 1
		push cs
		pop es
		mov bp, input
		add bp, [top]
		dec bp
		int 10h
		pop ebp
		ret

	coverLast: ;处理退格键，覆盖最后一个字符
		mov ax, 0b800h
		mov es, ax
		mov ah, 3h
		int 10h
		;此时dh，dl为行列位置
		; 退一格
		cmp dl, 0
		jg noEndofLine
		mov dl, 80
		dec dh
	noEndofLine:
		dec dl
		mov ah, 2h
		mov bh, 0
		int 10h

		mov ax, 80
		mul dh
		mov dh, 0
		add ax, dx
		mov dx, 2
		mul dx
		mov bx, ax
		
		mov word [es:bx], 0f20h
		ret

	Charminiret:
	pop es
	pop di
	pop dx
	pop bx

	ret
	input times 101 db 0
	top dw 0
	getInputTable dw charpush, charpop, charshow


_shutdown:
	mov ax, 5301h ;function 5301h
	xor bx, bx ;device id: 0000h (=system bios)
	int 15h ;call interrupt: 15h

	mov ax, 530eh ;function 530eh
	mov cx, 0102h ;driver version
	int 15h ;call interrupt: 15h

	mov ax, 5307h ;function 5307h
	mov bl, 01h ;device id: 0001h (=all devices)
	mov cx, 0003h ;power state: 0003h (=off)

	int 15h ;call interrupt: 15h

	pop ecx
	jmp cx

_load:
	;;;void load(int lma, int size, int vma);;;;;
	push ebp
	push es
	push ds
	mov ax, cs
	mov ds, ax
	mov ax, segOfUser
    mov es, ax                ;设置段地址（不能直接mov es,段地址）
 	
 	; 计算扇区
 	mov ax, word [esp+0xc]
 	mov dx, 0
 	mov cx, 512
 	div cx ;现在ax里面是相对扇区号
 	mov cx, 18
 	div cx ; 余数在dx里面
 	mov cl, dl
 	inc cl ; 起始扇区号确定

 	mov dx, ax
 	shr ax, 1
 	mov ch, al ;磁道号
 	mov dh, dl
 	and dh, 00000001b
 	mov dl, 0 	; 磁面号

 	; 计算大小
 	push cx
 	mov ax, word [esp+0x12]
    mov cx, 512
    mov dx, 0
    div cx ;al已设定
    pop cx

    mov bx, word [esp+0x14];偏移地址
    mov ah, 2 ;功能号
    int 13h
    pop ds
    pop es
    pop ebp
	pop ecx
	jmp cx


; _dispatch:
; 	; void dispatch(struct PCB * kernel, struct PCB * pro);;
; 	push ax
; 	mov ax, [esp+6]
; 	mov word [old_process], ax
; 	mov ax, [esp+0xa]
; 	mov word [new_process], ax
; 	pop ax

; 	call save
; 	call restart


; 	; 先保存当前进程控制块(0),再进入参数指定的进程
; 	; 方案是PCB表放在内核所在的段\
; 	; 此时栈中应该有ip(进程)\ip(调度函数或中断,应舍弃)
; save:
; 	pop word [store_ax]
; 	;此时栈中为进程ip
; 	push ds
; 	;;;;切换到内核栈(PCB表所在);;;;;
; 	push ax
; 	mov ax, segOfOs
; 	mov cs, ax
; 	pop ax
	
; 	push cs
; 	pop ds
; 	push si
; 	push di
; 	mov si, [new_process] ;new_process
; 	mov di, [old_process] ;old_process

; 	pop word [store_di] ;di
; 	pop word [store_si] ;si
; 	pop word [store_ds] ;ds
; 	pop word [store_ip] ;ip
; 	;;;sp恢复到进入函数之前的值;;;;
; 	mov word [di+16*2], ss
; 	mov word [di+15*2], sp
; 	push cs
; 	pop ss
; 	add di, 14*2
; 	mov sp, di
; 	pushf
; 	push cs
; 	push word [store_ip]
; 	pusha
; 	;;; si,di have been changed;;;;
; 	pop di ;si
; 	pop di

; 	push word [store_si]
; 	push word [store_di]
; 	push word [store_ds]

; 	push es
; 	push fs
; 	push gs


; restart:
; 	;;注意调用时的压栈等等
; 	push ax

; 	mov ax, cs
; 	mov ds, ax
; 	mov ss, ax

; 	pop ax
; 	;;;切换到PCB表;;;;
; 	mov sp, di
; 	;;restore
; 	pop gs
; 	pop fs
; 	pop es
; 	pop ds
; 	popa

; 	pop word [cs:store_ip]
; 	pop word [cs:store_cs]
; 	popf
; 	pop word [cs:store_sp]
; 	pop ss
	
; 	mov word [cs:store_ax], ax
; 	mov ax, word [cs:store_sp]
; 	mov sp, ax
; 	mov ax, word [cs:store_ax]

; 	pushf
; 	push word [cs:store_cs]
; 	push word [cs:store_ip]

; 	iret

; 	new_process dw 0
; 	old_process dw 0
; 	store_ax dw 0
; 	store_di dw 0
; 	store_si dw 0
; 	store_ds dw 0
; 	store_ip dw 0
; 	store_cs dw 0
; 	store_ss dw 0
; 	store_sp dw 0
; 	; new_process dw 0
; 	; kernel dw 0



_dispatch:
	;;;  void dispatch(int address)  ;;;;;;
	pusha
	mov bx, word [esp+0x14]
	mov word [target], bx
	mov ax, segOfUser
	mov word [target+2], ax
	push ds
	push es
	pushf
	mov ax, ss
	mov [stroes], ax

	
	mov ax, segOfUser
	; mov ds, ax
	mov es, ax
	mov ss, ax
	mov word[stroes+2], sp
	mov sp, 0xffff

    call far [target]
    ;;;;cs ip;;;;;
   	mov ax, cs
   	mov ds, ax
   	mov ss, [stroes]
   	mov sp, word [stroes+2]
   	;;ss;;
   	popf
    pop es
    pop ds

    popa

	pop ecx
	jmp cx

	stroes dw 0,0
	target dw 0,0

_reboot:
	;;;; _reboot() ;;;;;;;;;;;;;
	int 19h




_getDate:
	;;;; char * _getDate() ;;;;;;;;;;
	mov ah, 04h
	int 1ah

	;年
	mov bl, cl
	mov al, bl
	and al, 11110000b
	mov cl, 4
	shr al, cl

	and bl, 00001111b
	mov ah, bl
	add ax, 3030h
	mov word [date+6], '20'
	mov word [date+8], ax
	
	;月
	mov bl, dh
	mov al, bl
	and al, 11110000b
	mov cl, 4
	shr al, cl

	and bl, 00001111b
	mov ah, bl
	add ax, 3030h
	mov word [date+3], ax
	mov byte [date+5], '/'
	
	;日
	mov bl, dl
	mov al, bl
	and al, 11110000b
	mov cl, 4
	shr al, cl

	and bl, 00001111b
	mov ah, bl
	add ax, 3030h
	mov word [date], ax
	mov byte [date+2], '/'

	xor eax, eax
	mov ax, date

	pop ecx
	jmp cx

	date times 11 db 0
	; xx/xx/xxxx0

_roll:
	;;;;;;;; void roll();;;;;;;;
	;复制上一行
	push ebp

	mov ah, 06h
	mov al, 1
	mov bh, 0fh
	mov cx, 0000h
	mov dx, 184fh
	int 10h
	
    pop ebp
    pop ecx
    jmp cx

	lastline times 1920 db 0
	
_getRecords:
	;;; char * getRecords(int seg, int place) ;;;;;;;;;;;
	push ebp
	mov ax, cs
	mov ds, ax
	mov ax, word [esp+8h]
	mov es, ax
	xor ebx, ebx
	mov ebx, [esp+0ch]
	xor eax, eax
	; mov ax, cs
	; mov cl, 4
	; shl eax, cl
	; add eax, ebx
	mov eax, ebx

	pop ebp
	pop ecx
	jmp cx