	.file	"cfile.c"
	.code16gcc
	.intel_syntax noprefix
/APP
	.code16gcc

/NO_APP
	.globl	_myMessage
	.data
	.align 4
_myMessage:
	.ascii "AaBbCcDdEe\0"
	.text
	.globl	_myUpper
	.def	_myUpper;	.scl	2;	.type	32;	.endef
_myUpper:
LFB0:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	sub	esp, 4
	mov	DWORD PTR [ebp-4], 0
	jmp	L2
L4:
	mov	eax, DWORD PTR [ebp-4]
	add	eax, OFFSET FLAT:_myMessage
	mov	al, BYTE PTR [eax]
	cmp	al, 96
	jle	L3
	mov	eax, DWORD PTR [ebp-4]
	add	eax, OFFSET FLAT:_myMessage
	mov	al, BYTE PTR [eax]
	cmp	al, 122
	jg	L3
	mov	eax, DWORD PTR [ebp-4]
	add	eax, OFFSET FLAT:_myMessage
	mov	al, BYTE PTR [eax]
	sub	eax, 32
	mov	dl, al
	mov	eax, DWORD PTR [ebp-4]
	add	eax, OFFSET FLAT:_myMessage
	mov	BYTE PTR [eax], dl
L3:
	inc	DWORD PTR [ebp-4]
L2:
	cmp	DWORD PTR [ebp-4], 10
	jle	L4
	nop
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
LFE0:
	.ident	"GCC: (MinGW.org GCC-6.3.0-1) 6.3.0"
