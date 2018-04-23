
; org 0e000h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; 右上角 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Start:
    mov ax,cs
    mov ds,ax         ; DS = CS       
    mov ax,0B800h       ; 文本窗口显存起始地址
    mov es,ax         ; ES = B800h

    mov byte [rdul],Dn_Lt
    mov byte [occurence], IniOccur
    call clearprint


    

loopBall: 
    dec byte [occurence]
    jz reto
    call delayModule
    call moveBall
    call checkInput
    jmp loopBall

reto:
    call re


moveBall:
    mov al,11h
    cmp al,byte[rdul]
      jz DnRt
    mov al,01h
    cmp al,byte[rdul]
      jz UpRt
    mov al,00h
    cmp al,byte[rdul]
      jz UpLt    
    mov al,10h
    cmp al,byte[rdul]
      jz DnLt
    jmp $

    DnRt:
        inc word [x]
        inc word [y]
        mov bx,word [x]
        mov ax,[boundry+2]
        sub ax,bx
            jnz DnRtNext
            call  d2u
    DnRtNext:
        mov bx,word [y]
        mov ax,[boundry+6]
        sub ax,bx
            jnz DnRtShow
            call  r2l
    DnRtShow:
        mov ax, word[x]
        mov bx, word[y]
        jmp show

    UpRt:
        dec word [x]
        inc word [y]
        mov bx,word [y]
        mov ax,[boundry+6]
        sub ax,bx
            jnz UpRtNext
            call r2l
    UpRtNext:
        mov bx,word [x]
        mov ax,[boundry+0]
        sub ax,bx
            jnz UpRtShow
            call u2d
    UpRtShow:
        mov ax, word[x]
        mov bx, word[y]
        jmp show

      
      
    UpLt:
        dec word [x]
        dec word [y]
        mov bx,word [x]
        mov ax,[boundry+0]
        sub ax,bx
            jnz UpLtNext
            call u2d
    UpLtNext:
        mov bx,word [y]
        mov ax,[boundry+4]
        sub ax,bx
            jnz UpLtShow
            call l2r
    UpLtShow:
        mov ax, word[x]
        mov bx, word[y]
        jmp show
      
    DnLt:
        inc word [x]
        dec word [y]
        mov bx,word [y]
        mov ax,[boundry+4]
        sub ax,bx
            jnz DnLtNext
            call l2r
    DnLtNext:
        mov bx,word [x]
        mov ax,[boundry+2]
        sub ax,bx
            jnz DnLtShow
            call d2u
    DnLtShow:
        mov ax, word[x]
        mov bx, word[y]
        jmp show

    d2u:
        mov ax, [boundry+2]
        mov word [x], ax
        sub word [x], 2
        and byte [rdul], 0Fh
        ret
        
    u2d:
        mov ax, [boundry+0]
        mov word [x], ax
        add word [x], 2
        xor byte [rdul], 10h
        ret

    r2l:
        mov ax, [boundry+6]
        mov word [y], ax
        sub word [y], 2
        and byte[rdul], 0F0h
        ret

    l2r:
        mov ax, [boundry+4]
        mov word [y], ax
        add word [y], 2
        xor byte[rdul], 01h
        ret


    Dn_Rt equ 11h                  ;D-Down,U-Up,R-right,L-Left
    Up_Rt equ 01h                  ;
    Up_Lt equ 00h                  ;
    Dn_Lt equ 10h                  ;       
    ;上下，左右
    x dw 0
    y dw 79
    boundry dw -1,12,41,80
    ; color db 5Fh 
    count db 0 

    rdul db Dn_Lt
    ; show equ 0c200h
    ; clearprint equ 0c800h
    ; checkInput equ 0c600h
re:
    int 2bh

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; modules ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
delayModule:
    delay equ 1000
    ddelay equ 200
    IniOccur equ 50
    mov word[dcount],delay
    mov word[ddcount],ddelay
    delayModule_loop1:
        dec word [dcount]                ; 递减计数变量
            jnz delayModule_loop1         ; >0：跳转;

        mov word[dcount],delay
        dec word[ddcount]
            jnz delayModule_loop1
    ret
    dcount dw delay
    ddcount dw ddelay
    occurence db IniOccur



show:
    mov word[show_x], ax
    mov word[show_y], bx
    mov ax, 0b800h
    mov es, ax
    inc byte [color]
    and byte [color],0Fh
    or byte [color],50h
    xor ax,ax                 ; 计算显存地址
    mov ax,di
    mov ax,word [show_x]
    mov bx, 80
    mul bx
    add ax,word [show_y]
    mov bx,2
    mul bx
    mov bx,ax
    mov ah,byte [color]        ;  0000：黑底、1111：亮白字（默认值为07h）
    mov al,'O'      ;  al = 显示字符值（默认值为20h=空格符）
    mov [es:bx],ax      ;  显示字符的ASCII码值

     
    ret
    ten db 10
    color db 5Fh 
    show_x dw 0
    show_y dw 0


clearprint: 
    push bx
    push cx
    push es
    mov bx,0b800h  
    mov es,bx
    mov bx,0
    mov cx,2000
    clear_print_real: 
        mov word [es:bx],5520h
        add bx,2
        loop clear_print_real
    ;;;;;; 分割屏幕 ;;;;;;;;;;

hline:
    mov cx, 80
    mov bx, 12*160
    draw_hline:
        mov word [es:bx], 0020h
        add bx, 2
        loop draw_hline

vline:
    mov cx, 25
    mov bx, 40*2
    draw_vline:
        mov word [es:bx], 0020h
        mov word [es:bx+2], 0020h
        add bx, 160
        loop draw_vline

    call printnames
    pop es
    pop cx
    pop bx
    ret

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

checkInput:
    pushf
    mov ah,01h
    int 16h
    jz checkInputre
    mov ah,00H
    int 16h
    cmp al, 'c'
    jnz next
    call clearprint
next:
    cmp al, 'q'
    jnz checkInputre
    popf
    int 2bh
    checkInputre:
        popf
        ret
