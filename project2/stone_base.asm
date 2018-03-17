org 07c00h  
    mov ax, cs  
    mov ds, ax  
; load_os:  
;     mov ah,02h                            ;读磁盘扇区  
;     mov al,06h                            ;读取1个扇区  
;     mov ch,00h                            ;起始磁道  
;     mov cl,02h                            ;起始扇区  
;     mov dh,00h                            ;磁头号  
;     mov dl,00h                            ;驱动器号  
;     mov bx,os                             ;存储缓冲区  
;     int 13h  
;     ret  

                             ;引导扇区标识,至此文件大小为512byte  
  
    Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
    Up_Rt equ 2                  ;
    Up_Lt equ 3                  ;
    Dn_Lt equ 4                  ;       

    delay equ 5000
    ddelay equ 200

    ; delay equ 65535     ; 计时器延迟计数,用于控制画框的速度   
    ; ddelay equ 2000     ; 计时器延迟计数,用于控制画框的速度
    
    x dw 5
    y dw 0
    dcount dw delay
    ddcount dw ddelay
    color db 5Fh 
    count db 0 
    ten db 10
    rdul db Dn_Rt
    
start:
    mov ax,cs
    mov ds,ax         ; DS = CS       
    ;mov ax,0100h
    mov ax,0B800h       ; 文本窗口显存起始地址
    mov es,ax         ; ES = B800h

    ; call printBigName
;     mov word [ddcount], 5000
;     mov word [dcount], 4000
; loopBigname:
;   dec word [dcount]
;     jnz loopBigname
;   mov word [dcount], 4000
;   dec word [ddcount]
;     jnz loopBigname
;   ; jmp loopBigname
;     mov word [dcount], delay
;     mov word [ddcount], ddelay

    ; call printnames
    ; call clearprint


loop1: 
  mov ah,01h
  int 16h
  jz loop2
  mov ah,00H
  int 16h
  cmp al, 'c'
  jnz loop2

  call clearprint

  loop2: 
    dec word [dcount]                ; 递减计数变量
        jnz loop1         ; >0：跳转;

    mov word[dcount],delay
    dec word[ddcount]
        jnz loop1
    mov word[dcount],delay
    mov word[ddcount],ddelay

    mov al,1
    cmp al,byte[rdul]
        jz DnRt
    mov al,2
    cmp al,byte[rdul]
        jz UpRt
    mov al,3
    cmp al,byte[rdul]
        jz UpLt    
    mov al,4
    cmp al,byte[rdul]
        jz DnLt
        jmp $

DnRt:
  ; mov word [es:480], 0f31h
  inc word [x]
  inc word [y]
  mov bx,word [x]
  mov ax,25
  sub ax,bx
        jz  dr2ur
  mov bx,word [y]
  mov ax,80
  sub ax,bx
        jz  dr2dl
  jmp show
  
dr2ur:
    ;inc byte [count]
    mov word [x],23
    mov byte[rdul],Up_Rt  
    jmp show
dr2dl:         
    ;inc byte [count]
    mov word [y],78
    mov byte[rdul],Dn_Lt  
    jmp show

UpRt:
  dec word [x]
  inc word [y]
  mov bx,word [y]
  mov ax,80
  sub ax,bx
        jz ur2ul
  mov bx,word [x]
  mov ax,0
  sub ax,bx
        jz ur2dr
  jmp show
ur2ul:
    ;inc byte [count]
    mov word [y],78
    mov byte[rdul],Up_Lt  
    jmp show
ur2dr:
    ;inc byte [count]
    mov word [x],1
    mov byte[rdul],Dn_Rt  
    jmp show

  
  
UpLt:
  dec word [x]
  dec word [y]
  mov bx,word [x]
  mov ax,0
  sub ax,bx
        jz ul2dl
  mov bx,word [y]
  mov ax,-1
  sub ax,bx
        jz ul2ur
  jmp show

ul2dl:
    ;inc byte [count]
    mov word [x],1
    mov byte[rdul],Dn_Lt  
    jmp show
ul2ur:
    ;inc byte [count]
    mov word [y],1
    mov byte[rdul],Up_Rt  
    jmp show

  
  
DnLt:
  inc word [x]
  dec word [y]
  mov bx,word [y]
  mov ax,-1
  sub ax,bx
        jz dl2dr
  mov bx,word [x]
  mov ax,25
  sub ax,bx
        jz dl2ul
  jmp show

dl2dr:
    ;inc byte [count]
    mov word [y],1
    mov byte[rdul],Dn_Rt  
    jmp show
  
dl2ul:        
    ;inc byte [count]
    mov word [x],23
    mov byte[rdul],Up_Lt  
    jmp show



  
show:
      call clearprint  
      call printnames
      inc byte [color]
      and byte [color],0Fh
      or byte [color],50h
      xor ax,ax                 ; 计算显存地址
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
 
      ; mov bx,140
      ; mov al, byte [count]
      ; xor ah,ah
      ; div byte [ten]         
      ; push ax  
      ; mov ah,0Fh
      ; add al,30H
      ; mov word [es:bx],ax
      ; pop ax
      ; mul byte [ten]
      ; push bx
      ; mov bl, byte [count]
      ; xor bh,bh
      ; sub bx,ax
      ; mov al,bl
      ; add al,30H
      ; mov ah,0Fh 
      ; pop bx
      ; mov word [es:bx+2],ax
      
     
      jmp loop1
  
; ending:
;     jmp $                   ; 停止画框，无限循环 


  
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
            mov cx,50
            mov dx,0005h
            push cs
            pop es
            mov bp,me
            mov ah,13h
            int 10h
          

            pop bp
            pop es
            pop dx
            pop cx
            pop bx
            pop ax
             
            ret
    me db "WANG XIHUAI 16337236 Press 'c' to clean the screen"


times 512-($-$$) db 0                     ;填充至510byte  
; dw 0xaa55    

; printBigName:
;     mov word [es:162], 0f31h
;     push ax
;     push bx
;     push cx
;     push dx
;     push es
;     push bp
    
;     mov al,1
;     mov bh,0
;     mov bl,5FH
;     mov cx,2000
;     mov dx,0000h
;     push cs
;     pop es
;     mov bp,named

;     mov ah,13h
;     int 10h
    

;     pop bp
;     pop es
;     pop dx
;     pop cx
;     pop bx
;     pop ax
     
;     ret    

; named db "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
; db "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$=$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ $$$$$$$$$$$$"
; db "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  ~$$$$!.$$$$$$  $$$$$$$$$$$$$$$ ,$$ $$$$$$$$$$$"
; db "$$$$$$$$$$$$$$$$$$$$$$$ $$$$$$$$  $$$$$! $$$$$$ .$$$$$$$. $$$$$= !$$  $$$$$$$$$$"
; db "$$$$$$                   $$$$$$$ $$$ $$* $$$$$$ ,$$$$$$$$  $$$$  $$$* $$$$$$$$$$"
; db "$$$$$$$$$$$$$$  $$$$$$$$$$$$$$$       $* ****** ,$$$$$$$$* $=$$ $$$$$$$$$  $$$$$"
; db "$$$$$$$$$$$$$$  $$$$$$$$$$$$$$$ $$$$$$$* $$$$$$ ,$$$$$$$$$$$ $~ $$$$ ~$$$$$$$$$$"
; db "$$$$$$$$$$$$$$  $$$$$$$$$$$$$$: $$$$$$$! $$$$$$ .$$$$$ $$$$$=$  $$$$ ~$$$$$$$$$$"
; db "$$$$$$$$$$$$$$  $$$$$$$$$$$$$$ $$$$  $$! ------ .$$$$$! *$$ $.~ $$$$ ~$$$$$$$$$$"
; db "$$$$$$$$$$$$$$  $$$$$$$$$$$$$,=$; $$$$$; .!$$$$ ;$$$$$$  $$ $.$ $$$$ ~$$  $$$$$$"
; db "$$$$$$$$$$$$$$  $$$$$$$$$$$$$!$$; $$$$$$$ -$$$$$$$$$$$$$ $,$~$$ $$$$ ~$$$$$$$$$$"
; db "$$$$$$$=======  =====  $$$$$$$$$; $$$$$$  ------, -$$$$$$$ $$$$ $$$$ ~$$$$$$$$$$"
; db "$$$$$$$$$$$$$$  $$$$$$$$$$$$$$$$; $, $$ .$: $$ $! $$$$$$$;~$$$$ $$$$ ~$$$$$$$$$$"
; db "$$$$$$$$$$$$$$  $$$$$$$$$$$$$$$$; $$$$.*$$ =$. $~ $$$$$$$ $$$$$ $$$$ ~$$. $$$$$$"
; db "$$$$$$$$$$$$$$  $$$$$$$$$$$$$$$$; $$$ $$$ -$$ $$. $$$$$$; $$$$$ ;;;; ,;;;;;$$$$$"
; db "$$$$$$$$$$$$$$  $$$$$$$$$$$$$$$$; $$$$$$ ~$$ .$$  $$$:!; =$$$$$ $$$$ ~$$$$$$$$$$"
; db "$$$$$$$$$$$$$$  $$$$$$$$$$$$$$$$; $$.$$ $$$  $$$  $$$$$  $$$$$$ $$$$ ~$$$$$$$$$$"
; db "$$$$$$$$$$$$$$  $$$$$$$$$$$$$$$$; $ $ =$$$- $$$$ ~$$$$$! $$$$$$ $$$$ ~$$$$;$$$$$"
; db "$$$$$$$$$$$$$$  $$$$$$$$-$$$$$$$;  $$$$$$. $$$$$ $$$$$$  $$$$$$ ---- .---  -$$$$"
; db "$$$$;;;;;;;;;;  ;;;;;;;   $$$$$$  $$$$$$ =$$. .  $$$$$$  $$$$$$ $$$$$$$$$$$$$$$$"
; db "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$=$$$$ =$$$$$=  $$$$$$$  $$$$$$ $$$$$$$$$$$$$$$$"
; db "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
; db "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
; db "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
; db "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"

; times 3584-($-$$) db 0