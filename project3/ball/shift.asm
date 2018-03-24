;程序源代码（myos1.asm）
;文件说明
; 偏移20个扇区
;扇区         程序
; 1           boot
; 2           ball_A
; 3           ball_B
; 4           ball_C
; 5           ball_D
; 6           showBall
; 7           printnames
; 8           checkinput
; 9           cleanPrint
; 10          printBigName

; 内存地址从a000h开始

    ; OffSetOfUserPrg equ b000h
    ; offSetOfShow equ a000h
    ; offSetOfNames equ a200h
    ; offSetOfCheck equ a400h
    ; offSetOfClear equ a600h
    ; offSetOfBigName equ a800h







org  7c00h		; BIOS将把引导扇区加载到0:7C00h处，并开始执行
start:
    mov ax, cs         ; 置其他段寄存器值与CS相同
    mov ds, ax         ; 数据段
    
    ;;;;;;;;;;;;;;;; 打印提示信息 ;;;;;;;;;;;;;;

   ;;;;es, dx, cx, 确定。;;;;;;;;;;
    mov ax,cs                ;段地址 ; 存放数据的内存基地址
    mov es,ax                ;设置段地址（不能直接mov es,段地址）
    mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,0                 ;磁头号 ; 起始编号为0
    mov ch,0                 ;柱面号 ; 起始编号为0


    call loadAll

    mov al,1
    mov bh,0
    mov bl,5FH
    mov cx,MessageLength
    mov dx,0005h
    push cs
    pop es
    mov bp,Message
    mov ah,13h
    int 10h
    call delayModule
    call offSetOfBigName
 call offSetOfClear

    ; cmp byte[ptr],-1
    ; jz runPrg
    ; mov bl, byte [ptr]
    ; mov bh, 0
    ; dec bx
    ; mov ah, 0
    ; mov al, byte [queue+bx]   
    ; mov bx, 200h
    ; mul bx
    ; add ax, OffSetOfUserPrg
    ; call ax
    ; dec byte[ptr]
runPrg:

    mov ah, 00h
    int 16h

    sub al, 31h
    cmp al, 5
    jge runPrg
    mov bx, 200h
    mul bx
    add ax, OffSetOfUserPrg
    call ax


    jmp runPrg


loadAll:
    push es
    push cx
    push dx

    mov cx, 4
loadAllPrg:
    dec cx
    mov ax, cx
    inc cx
    mov bx, 200h
    mul bx 
    add ax, OffSetOfUserPrg
    mov dx, ax   
    call loadPrg
    loop loadAllPrg
    pop dx
    pop cx
    pop es

    ; call ChangeInt9
    call installInt2Bh

loadShow:
    mov bx,offSetOfShow  ;偏移地址; 存放数据的内存偏移地址
    mov ah,2                 ; 功能号
    mov al,1                 ;扇区数
    mov cl,6                 ;起始扇区号 ; 起始编号为1
    int 13H ;                调用读磁盘BIOS的13h功能

loadNames:
    mov bx,offSetOfNames  ;偏移地址; 存放数据的内存偏移地址
    mov ah,2                 ; 功能号
    mov al,1                 ;扇区数
    mov cl,7                 ;起始扇区号 ; 起始编号为1
    int 13H ;                调用读磁盘BIOS的13h功能


loadCheck:
    mov bx,offSetOfCheck  ;偏移地址; 存放数据的内存偏移地址
    mov ah,2                 ; 功能号
    mov al,1                 ;扇区数
    mov cl,8                 ;起始扇区号 ; 起始编号为1
    int 13H ;                调用读磁盘BIOS的13h功能

loadClear:
    mov bx,offSetOfClear  ;偏移地址; 存放数据的内存偏移地址
    mov ah,2                 ; 功能号
    mov al,1                 ;扇区数
    mov cl,9                 ;起始扇区号 ; 起始编号为1
    int 13H ;                调用读磁盘BIOS的13h功能

loadBigName:
    mov bx,offSetOfBigName  ;偏移地址; 存放数据的内存偏移地址
    mov ah,2                 ; 功能号
    mov al,6                 ;扇区数
    mov cl,10                 ;起始扇区号 ; 起始编号为1
    int 13H ;                调用读磁盘BIOS的13h功能

    ; call offSetOfNames
    ; jmp OffSetOfUserPrg

;;;;;;;;;;;;这段代码没有恢复原中断;;;;;;;;;;
    ; push [ds:0]
    ; pop [es:9*4]
    ; push [ds:2]
    ; pop [es:9*4+2]

    ; jmp $                      ;无限循环

    ret ;loadAll

;;;;;;;;;;;;;;;;;; 需要dx ;;;;;;;;;;;;;;;;;;;;
loadPrg:
    push cx
    push bx
    push ax

    mov bx,dx  ;偏移地址; 存放数据的内存偏移地址
    inc cx     ;起始扇区号
    mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,0                 ;磁头号 ; 起始编号为0
    mov ch,0                 ;柱面号 ; 起始编号为0
    mov ah,2                 ; 功能号
    mov al,1                 ;扇区数
    int 13H ;                调用读磁盘BIOS的13h功能

    pop ax
    pop bx
    pop cx

    ret


installInt2Bh:
    mov ax, 0
    mov es, ax
    mov word [es:2bh*4], int2Bh
    mov [es:2bh*4+2], cs
    ret
    int2Bh:
        popf
        pop ax ;CS
        pop ax ;IP

        pop ax ;IP

        jmp runPrg

    ; mov cl,2                 ;起始扇区号 ; 起始编号为1

; ChangeInt9:
;     mov ax, 0
;     mov es, ax

;     mov ax, word [es:9*4]
;     push ax
;     mov ax, word [OrgInt9]
;     pop ax
;     mov ax, word [es:9*4+2]
;     push ax
;     mov ax, word [OrgInt9+2]
;     pop ax

;     cli 
;     mov word [es:9*4],Int9
;     mov word [es:9*4+2],cs
;     sti

;     ret

;     Int9:
        
;         push ax
;         push bx
;         push es
;         push di

;         ; in al,60h

;         ; pushf
;         ; pushf
;         ; pop bx
;         ; and bh, 1111110b
;         ; push bx
;         ; popf
;         ; call dword [ds:0]

;         ; cmp byte [ptr],10
;         ;     jg Int9ret
;         ; inc byte [ptr]
;         ; mov di, [ptr]
;         ; dec al
;         ; mov byte [queue+di],al
;         mov ax, 0b800h
;         mov es, ax
;         mov al, '0'
;         mov ah, byte [color]
;         inc byte [color]
;         mov [es:0], ax


;     Int9ret:
;         pop di
;         pop es
;         pop bx
;         pop ax

;         iret
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; modules ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
    delayModule:
        delay equ 2000
        ddelay equ 2000
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
        
    OffSetOfUserPrg equ b000h
    offSetOfShow equ a000h
    offSetOfNames equ a200h
    offSetOfCheck equ a400h
    offSetOfClear equ a600h
    offSetOfBigName equ a800h
    OrgInt9 times 2 dw 0
    ; queue times 10 db 0
    ; queue db 1,2,3,4,0,0,0,0,0,0
    ; ptr db -1
    ; ptr db 3
    Message db 'Hello, MyOs is loading user programs­'
    MessageLength  equ ($-Message)
    color db 5fh
    times 510-($-$$) db 0
    dw 0AA55h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    







