org 0e000h

mov ax, cs
mov ds, ax

mov ah, 04h
int 21h

mov ah, 00h 
int 21h

mov ah, 01h
mov al, 01h
int 21h

mov ah, 03h
int 21h


mov bx, 10
mov di, strings
mov ax, ds
mov gs, ax
mov ah, 05h
int 21h

mov di, strings
mov dh, 10
mov dl, 20
mov cx, 2
mov bh, 0x0f
mov ax, ds
mov gs, ax
mov ah, 02h 
int 21h

mov ax, 00h
int 16h

call re
re:
	int 2bh

strings times 20 db 0