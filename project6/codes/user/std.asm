[BITS 16]

global _printSentence
global _fork
global _exitprg
global _wait
global _getchar
global _malloc

[section .text]
_fork:
; int fork();

	mov ah, 8
	int 21h

	pop ecx

	jmp cx


_exitprg:
; void exitprg(int exit_value);
	push ebp
	mov ebp, esp

	push bx
	push ax

	mov bx, word [ss:ebp+8]
	push bx
	mov ah, 6
	int 21h

	pop bx

	pop ax
	pop bx

	mov esp, ebp
	pop ebp

	pop ecx

	jmp cx



_wait:
; int wait();
	push ebp
	mov ebp, esp

	mov ah, 7
	int 21h

	mov esp, ebp
	pop ebp

	pop ecx

	jmp cx

_malloc:
; void * malloc(size)
	push ebp
	mov ebp, esp
	push gs
	push ds
	pop gs

	push ebx
	mov ebx, [ebp+8]
	mov ah, 0x9
	int 21h
	pop ebx

	pop gs
	mov esp, ebp
	pop ebp

	pop ecx

	jmp cx







_printSentence:
;;;; void printSentence(char * message, int x, int y, int len, int color);
;;;; _printSentence(message, dh, dl, len, color) ;;;;;
;;;; di, dh, dl, cx, bl, gs ;;;;;

push ebp
mov ebp, esp
pusha
push gs

mov di, word [ebp+8]
mov dh, byte [ebp+12]
mov dl, byte [ebp+16]
mov cx, word [ebp+20]
mov bl, byte [ebp+24]

push ds
pop gs

mov ah, 2
int 21h

pop gs
popa
mov esp, ebp
pop ebp

pop ecx
jmp cx

_getchar:
; char getchar();
mov ah, 0
int 16h
mov al, ah
mov ah, 0

pop ecx
jmp cx
