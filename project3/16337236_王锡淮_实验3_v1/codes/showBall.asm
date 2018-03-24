org 0c200h
;;;;;;;;;;;;;;;;;;;;;;;;;;; 接口：x-ax, y-bx ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

show:
    mov word[x], ax
    mov word[y], bx
    mov ax, 0b800h
    mov es, ax
    inc byte [color]
    and byte [color],0Fh
    or byte [color],50h
    xor ax,ax                 ; 计算显存地址
    mov ax,di
    mov ax,word [x]
    mov bx, 80
    mul bx
    add ax,word [y]
    mov bx,2
    mul bx
    mov bx,ax
    mov ah,byte [color]        ;  0000：黑底、1111：亮白字（默认值为07h）
    mov al,'O'      ;  al = 显示字符值（默认值为20h=空格符）
    mov [es:bx],ax      ;  显示字符的ASCII码值

     
    ret
    ten db 10
    color db 5Fh 
    x dw 0
    y dw 0