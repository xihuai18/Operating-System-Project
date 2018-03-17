org 9200h
printnames: 
    push ax
    push bx
    push cx
    push dx
    push es
    push bp

    mov al,1
    mov bh,0
    mov bl,5FH
    mov cx,len
    mov dx,0005h
    push cs
    pop es
    mov bp,msg
    mov ah,13h
    int 10h
  

    pop bp
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
     
    ret
    msg db "WANG XIHUAI 16337236 Press 'c' to clean the screen"
    times 30 db 0
    db "Press 1-4 to call the reflecting balls"
    len equ $-msg