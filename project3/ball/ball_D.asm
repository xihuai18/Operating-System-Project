org 8600h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; 左下角 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Start:
    mov ax,cs
    mov ds,ax         ; DS = CS       
    mov ax,0B800h       ; 文本窗口显存起始地址
    mov es,ax         ; ES = B800h

    mov byte [rdul],Up_Lt
    mov byte [occurence], IniOccur
    call clearprint


    

loopBall: 
    dec byte [occurence]
    jz re
    call delayModule
    call moveBall
    call checkInput
    jmp loopBall


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
    x dw 13
    y dw 79
    boundry dw 12,25,41,80
    color db 5Fh 
    count db 0 

    rdul db Up_Lt
    show equ 9000h
    clearprint equ 9600h
    checkInput equ 9400h
re:
    ret 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; modules ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
delayModule:
    delay equ 2000
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



