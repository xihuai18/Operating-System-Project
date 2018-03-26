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

[section .text]
_printSentence:
	;;; _printSentence(message, dh, dl, len) ;;;;;
	push ebp
	mov ax, cs
	mov ds, ax
	mov es, ax
 	
 	mov cx, word [esp+14h]
 	mov dl, byte [esp+10h]; 列
 	mov dh, byte [esp+0ch]; 行
 	mov bp, word [esp+08h]
	mov al,1
    mov bh,0
    mov bl,0fh          ;白底黑字
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
		mov ah, 3h
		int 10h
		;此时dh，dl为行列位置
		mov al, 1h ; 光标位置改变
		mov ah, 13h
		mov bh, 0
		mov bl, 0fh ;黑底白字
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

_dispatch:
	;;;  void dispatch(int address, int size)  ;;;;;;
	offsetOfUserPrg equ 0e000h
	push ebp
	mov ax, cs
	mov ds, ax
    mov es, ax                ;设置段地址（不能直接mov es,段地址）
 	
 	; 计算扇区
 	mov ax, word [esp+0x8]
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
 	mov ax, word [esp+0xe]
    mov cx, 512
    mov dx, 0
    div cx ;al已设定
    pop cx

    mov bx, offsetOfUserPrg;偏移地址
    mov ah, 2 ;功能号
    int 13h

    call bx

    pop ebp
	pop ecx
	jmp cx


_reboot:
	;;;; _reboot() ;;;;;;;;;;;;;
	int 19h


_getManual:
	;;;; char * getManual();;;;;;;;
	offSetOfManual equ 0ec00h
	xor eax, eax
	mov eax, offSetOfManual

	pop ecx
	jmp cx

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
	; mov ax, 0xb800
	; mov es, ax
	; mov si, 160
	; mov ax, cs
	; mov ds, ax
	; mov bx, 0

	; mov cx, 1920

	; movbyte:
	; 	mov al, byte [es:si]
	; 	mov byte [lastline+bx], al
	; 	inc bx
	; 	add si, 2
	; 	loop movbyte

	mov ah, 06h
	mov al, 1
	mov bh, 0fh
	mov cx, 0000h
	mov dx, 184fh
	int 10h
	; mov ah, 06h
	; mov al, 1
	; mov bh, 0fh
	; mov cx, 0000h
	; mov dx, 184fh
	; int 10h

	; mov ax, cs
	; mov ds, ax
	; mov es, ax
 	
	; mov al,1
 ;    mov bh,0
 ;    mov bl,0fh          ;白底黑字
 ;    mov bp, lastline
 ;    mov cx, 1920
 ;    mov dh, 0
 ;    mov dl, 0
 ;    mov ah,13h
 ;    int 10h

    pop ebp
    pop ecx
    jmp cx

	lastline times 1920 db 0