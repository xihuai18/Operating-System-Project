;程序源代码（myos1.asm）
org  7c00h		; BIOS将把引导扇区加载到0:7C00h处，并开始执行
OffSetOfUserPrg1 equ 8100h
Start:
	mov	ax, cs	       ; 置其他段寄存器值与CS相同
	mov	ds, ax	       ; 数据段
	mov	bp, Message		 ; BP=当前串的偏移地址
	mov	ax, ds		 ; ES:BP = 串地址
	mov	es, ax		 ; 置ES=DS
	mov	cx, MessageLength  ; CX = 串长（=9）
	mov	ax, 1301h		 ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	mov	bx, 0007h		 ; 页号为0(BH = 0) 黑底白字(BL = 07h)
      mov dh, 0		       ; 行号=0
	mov	dl, 0			 ; 列号=0
	int	10h			 ; BIOS的10h功能：显示一行字符
LoadnEx:
     ;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
      mov ax,cs                ;段地址 ; 存放数据的内存基地址
      mov es,ax                ;设置段地址（不能直接mov es,段地址）
      mov bx, OffSetOfUserPrg1  ;偏移地址; 存放数据的内存偏移地址
      mov ah,2                 ; 功能号
      mov al,1                 ;扇区数
      mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
      mov dh,0                 ;磁头号 ; 起始编号为0
      mov ch,0                 ;柱面号 ; 起始编号为0
      mov cl,2                 ;起始扇区号 ; 起始编号为1
      int 13H ;                调用读磁盘BIOS的13h功能
      ; 用户程序a.com已加载到指定内存区域中
      jmp OffSetOfUserPrg1
AfterRun:
      jmp $                      ;无限循环
Message:
      db 'Hello, MyOs is loading user program A.COM…'
MessageLength  equ ($-Message)
      times 510-($-$$) db 0
      db 0x55,0xaa

org 8100h 
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
    mov ax,0B800h       ; 文本窗口显存起始地址
    mov es,ax         ; ES = B800h


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
    mov word [x],23
    mov byte[rdul],Up_Rt  
    jmp show
dr2dl:         
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
    mov word [y],78
    mov byte[rdul],Up_Lt  
    jmp show
ur2dr:
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
    mov word [x],1
    mov byte[rdul],Dn_Lt  
    jmp show
ul2ur:
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
    mov word [y],1
    mov byte[rdul],Dn_Rt  
    jmp show
  
dl2ul:        
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

     
      jmp loop1

  
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