	.file	"os.c"
	.code16gcc
/APP
	mov $0, %eax

	mov %ax, %ds

	mov %ax, %es

	jmpl $0, $__main

/NO_APP
	.globl	_line
	.bss
	.align 4
_line:
	.space 4
	.comm	_information, 320, 5
	.comm	_no, 32, 5
	.globl	_exitSen
	.section .rdata,"dr"
LC0:
	.ascii "exit\0"
	.data
	.align 4
_exitSen:
	.long	LC0
	.globl	_rebootSen
	.section .rdata,"dr"
LC1:
	.ascii "reboot\0"
	.data
	.align 4
_rebootSen:
	.long	LC1
	.globl	_clearSen
	.section .rdata,"dr"
LC2:
	.ascii "clear\0"
	.data
	.align 4
_clearSen:
	.long	LC2
	.globl	_dateSen
	.section .rdata,"dr"
LC3:
	.ascii "date\0"
	.data
	.align 4
_dateSen:
	.long	LC3
	.globl	_manSen
	.section .rdata,"dr"
LC4:
	.ascii "man\0"
	.data
	.align 4
_manSen:
	.long	LC4
	.globl	_lsSen
	.section .rdata,"dr"
LC5:
	.ascii "ls\0"
	.data
	.align 4
_lsSen:
	.long	LC5
	.text
	.globl	__main
	.def	__main;	.scl	2;	.type	32;	.endef
__main:
LFB0:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	pushl	%edi
	pushl	%esi
	pushl	%ebx
	subl	$44, %esp
	.cfi_offset 7, -12
	.cfi_offset 6, -16
	.cfi_offset 3, -20
	call	_initialFile
	movl	$1, (%esp)
	call	_initialScreen
	leal	-48(%ebp), %eax
	movl	$_no, %ebx
	movl	$8, %edx
	movl	%eax, %edi
	movl	%ebx, %esi
	movl	%edx, %ecx
	rep movsl
L9:
	call	_input
	movl	%eax, -16(%ebp)
	movl	-16(%ebp), %eax
	movb	(%eax), %al
	cmpb	$46, %al
	jne	L2
	movl	-16(%ebp), %eax
	incl	%eax
	movb	(%eax), %al
	cmpb	$47, %al
	jne	L2
	movl	-16(%ebp), %eax
	leal	2(%eax), %edx
	leal	-48(%ebp), %eax
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	_find
	movl	-20(%ebp), %eax
	testl	%eax, %eax
	je	L4
	movl	-44(%ebp), %edx
	movl	-48(%ebp), %eax
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	_dispatch
	call	_clear
	leal	-48(%ebp), %eax
	movl	$_no, %ebx
	movl	$8, %edx
	movl	%eax, %edi
	movl	%ebx, %esi
	movl	%edx, %ecx
	rep movsl
	jmp	L4
L2:
	movl	_rebootSen, %eax
	movl	%eax, 4(%esp)
	movl	-16(%ebp), %eax
	movl	%eax, (%esp)
	call	_strcmp
	testl	%eax, %eax
	jne	L5
	call	_reboot
L5:
	movl	_clearSen, %eax
	movl	%eax, 4(%esp)
	movl	-16(%ebp), %eax
	movl	%eax, (%esp)
	call	_strcmp
	testl	%eax, %eax
	jne	L6
	call	_clear
L6:
	movl	_dateSen, %eax
	movl	%eax, 4(%esp)
	movl	-16(%ebp), %eax
	movl	%eax, (%esp)
	call	_strcmp
	testl	%eax, %eax
	jne	L7
	call	_date
L7:
	movl	_manSen, %eax
	movl	%eax, 4(%esp)
	movl	-16(%ebp), %eax
	movl	%eax, (%esp)
	call	_strcmp
	testl	%eax, %eax
	jne	L8
	call	_man
L8:
	movl	_lsSen, %eax
	movl	%eax, 4(%esp)
	movl	-16(%ebp), %eax
	movl	%eax, (%esp)
	call	_strcmp
	testl	%eax, %eax
	jne	L4
	call	_ls
L4:
	call	_newline
	movl	_exitSen, %eax
	movl	%eax, 4(%esp)
	movl	-16(%ebp), %eax
	movl	%eax, (%esp)
	call	_strcmp
	testl	%eax, %eax
	jne	L9
	call	_shutdown
	movl	$0, %eax
	addl	$44, %esp
	popl	%ebx
	.cfi_restore 3
	popl	%esi
	.cfi_restore 6
	popl	%edi
	.cfi_restore 7
	popl	%ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
LFE0:
	.ident	"GCC: (MinGW.org GCC-6.3.0-1) 6.3.0"
	.def	_initialFile;	.scl	2;	.type	32;	.endef
	.def	_initialScreen;	.scl	2;	.type	32;	.endef
	.def	_input;	.scl	2;	.type	32;	.endef
	.def	_find;	.scl	2;	.type	32;	.endef
	.def	_dispatch;	.scl	2;	.type	32;	.endef
	.def	_clear;	.scl	2;	.type	32;	.endef
	.def	_strcmp;	.scl	2;	.type	32;	.endef
	.def	_reboot;	.scl	2;	.type	32;	.endef
	.def	_date;	.scl	2;	.type	32;	.endef
	.def	_man;	.scl	2;	.type	32;	.endef
	.def	_ls;	.scl	2;	.type	32;	.endef
	.def	_newline;	.scl	2;	.type	32;	.endef
	.def	_shutdown;	.scl	2;	.type	32;	.endef
