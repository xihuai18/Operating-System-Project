;程序源代码（myos1.asm）
org  7c00h		; BIOS将把引导扇区加载到0:7C00h处，并开始执行
; start:
;     mov ax, cs         ; 置其他段寄存器值与CS相同
;     mov ds, ax         ; 数据段
    
;    ;;;;es, dx, cx, 确定。
;     mov ax,cs                ;段地址 ; 存放数据的内存基地址
;     mov es,ax                ;设置段地址（不能直接mov es,段地址）
;     mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
;     mov dh,0                 ;磁头号 ; 起始编号为0
;     mov ch,0                 ;柱面号 ; 起始编号为0


    ; call loadAll

 ; call clearprint

; runPrg:
;     cmp byte[ptr],-1
;     jz runPrg
;     mov bl, byte [ptr]
;     mov bh, 0
;     mov ah, 0
;     mov al, byte [queue+bx]   
;     mov bx, 200h
;     mul bx
;     add ax, OffSetOfUserPrg
;     call ax
;     jmp runPrg


; loadAll:
;     push es
;     push cx
;     push dx

;     mov cx, 4
; loadAllPrg:
;     dec cx
;     mov ax, cx
;     inc cx
;     mov bx, 200h
;     mul bx 
;     add ax, OffSetOfUserPrg
;     mov dx, ax   
;     call loadPrg
;     loop loadAllPrg

;     call ChangeInt9
;     pop dx
;     pop cx
;     pop es


; loadShow:
;     mov bx,offSetOfShow  ;偏移地址; 存放数据的内存偏移地址
;     mov ah,2                 ; 功能号
;     mov al,1                 ;扇区数
;     mov cl,4                 ;起始扇区号 ; 起始编号为1
;     int 13H ;                调用读磁盘BIOS的13h功能

; loadNames:
;     mov bx,offsetOfNames  ;偏移地址; 存放数据的内存偏移地址
;     mov ah,2                 ; 功能号
;     mov al,1                 ;扇区数
;     mov cl,5                 ;起始扇区号 ; 起始编号为1
;     int 13H ;                调用读磁盘BIOS的13h功能


; loadCheck:
;     mov bx,offSetOfCheck  ;偏移地址; 存放数据的内存偏移地址
;     mov ah,2                 ; 功能号
;     mov al,1                 ;扇区数
;     mov cl,6                 ;起始扇区号 ; 起始编号为1
;     int 13H ;                调用读磁盘BIOS的13h功能

; loadClear:
;     mov bx,offSetOfClear  ;偏移地址; 存放数据的内存偏移地址
;     mov ah,2                 ; 功能号
;     mov al,1                 ;扇区数
;     mov cl,7                 ;起始扇区号 ; 起始编号为1
;     int 13H ;                调用读磁盘BIOS的13h功能

;     ; call offsetOfNames
;     ; jmp OffSetOfUserPrg

; ;;;;;;;;;;;;这段代码没有恢复原中断;;;;;;;;;;
;     ; push [ds:0]
;     ; pop [es:9*4]
;     ; push [ds:2]
;     ; pop [es:9*4+2]

;     ; jmp $                      ;无限循环

;     ret ;loadAll

; ;;;;;;;;;;;;;;;;;; 需要dx ;;;;;;;;;;;;;;;;;;;;
; loadPrg:
;     push cx
;     push bx
;     push ax

;     mov bx,dx  ;偏移地址; 存放数据的内存偏移地址

;     dec cx
;     mov ax,cx
;     mov cx,2
;     mul cx
;     add ax,2
;     mov cl,al


;     mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
;     mov dh,0                 ;磁头号 ; 起始编号为0
;     mov ch,0                 ;柱面号 ; 起始编号为0

    
;     mov ah,2                 ; 功能号
;     mov al,2                 ;扇区数
    
;     ; mov cl,2                 ;起始扇区号 ; 起始编号为1
;     int 13H ;                调用读磁盘BIOS的13h功能
    
;     pop ax
;     pop bx
;     pop cx

;     ret

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

;         in al,60h

;         pushf
;         pushf
;         pop bx
;         and bh, 1111110b
;         push bx
;         popf
;         call dword [ds:0]

;         cmp byte [ptr],10
;             jg Int9ret
;         inc byte [ptr]
;         mov di, [ptr]
;         dec al
;         mov byte [queue+di],al


;     Int9ret:
;         pop di
;         pop es
;         pop bx
;         pop ax

;         iret

    ; OffSetOfUserPrg equ 8000h
    ; offSetOfShow equ 9000h
    ; offsetOfNames equ 9200h
    ; offSetOfCheck equ 9400h
    ; offSetOfClear equ 9600h
    ; clearprint equ 9600h
    ; OrgInt9 times 2 dw 0
    ; ; queue times 10 db 0
    ; queue db 1,2,3,4,0,0,0,0,0,0
    ; ; ptr db -1
    ; ptr db 3
    times 510-($-$$) db 0
    dw 0AA55h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    







