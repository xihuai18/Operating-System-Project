org 0c600h
checkInput:
    pushf
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
    popf
    int 2bh
    re:
        popf
        ret

clearprint equ 0c800h