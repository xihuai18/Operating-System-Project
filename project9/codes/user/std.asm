[BITS 16]

global _printSentence
global _fork
global _exitprg
global _wait
global _getchar
global _malloc
global _p
global _v
global _getsem
global _freesem
global _delay
global _clear
global _free

[section .text]
_clear:
	push ax
	mov ah, 4
	int 21h
	pop ax

	pop dword [cs:retaddr]

	jmp word [cs:retaddr]




_fork:
; int fork();

	mov ah, 8
	int 21h
	pop dword [cs:retaddr]

	jmp word [cs:retaddr]

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

	pop dword [cs:retaddr]

	jmp word [cs:retaddr]



_wait:
; int wait();
	push ebp
	mov ebp, esp

	mov ah, 7
	int 21h

	mov esp, ebp
	pop ebp

	pop dword [cs:retaddr]

	jmp word [cs:retaddr]

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

	pop dword [cs:retaddr]

	jmp word [cs:retaddr]


_free:
; void free(void * ptr)
	push ebp
	mov ebp, esp
	push gs
	push ds
	pop gs

	push ecx
	mov ecx, [ebp+8]
	mov ah, 15
	int 21h
	pop ecx

	pop gs
	mov esp, ebp
	pop ebp

	pop dword [cs:retaddr]

	jmp word [cs:retaddr]





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
mov ah, 0
pop dword [cs:retaddr]

jmp word [cs:retaddr]

_p:
; void p(int sem_id);
	push ebp
	mov ebp, esp

	push ecx
	push eax
	mov ecx, [ebp+8]

	mov ah, 12
	int 21h

	pop eax
	pop ecx

	mov esp, ebp
	pop ebp

	pop dword [cs:retaddr]

	jmp word [cs:retaddr]

	retaddr dd 0

_v:
; void v(int sem_id);

	push ebp
	mov ebp, esp

	push ecx
	push eax
	mov ecx, [ebp+8]

	mov ah, 13
	int 21h

	pop eax
	pop ecx

	mov esp, ebp
	pop ebp

	pop dword [cs:retaddr]

	jmp word [cs:retaddr]


_getsem:
; int getsem(int resourceSize);
	
	push ebp
	mov ebp, esp

	push ecx

	mov ecx, [ebp+8]

	mov ah, 10
	int 21h

	pop ecx

	mov esp, ebp
	pop ebp

	pop dword [cs:retaddr]

	jmp word [cs:retaddr]


_freesem:
; void freesem(int sem_id);
	push ebp
	mov ebp, esp

	push ecx
	push eax
	mov ecx, [ebp+8]

	mov ah, 11
	int 21h

	pop eax
	pop ecx

	mov esp, ebp
	pop ebp

	pop dword [cs:retaddr]

	jmp word [cs:retaddr]

_delay:
; void delay(int clocks);
	push ebp
	mov ebp, esp

	push ecx
	push eax
	mov ecx, [ebp+8]

	mov ah, 14
	int 21h

	pop eax
	pop ecx

	mov esp, ebp
	pop ebp

	pop dword [cs:retaddr]

	jmp word [cs:retaddr]