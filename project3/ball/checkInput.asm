org 9400h
checkInput:
    mov ah,01h
    int 16h
    jz re
    mov ah,00H
    int 16h
    cmp al, 'c'
    jnz next
    call clearprint
next:
    cmp al, 'q'
    jnz re
    int 2bh
    re:
        ret

clearprint equ 9600h