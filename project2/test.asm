; org 7c00h

; ; call ChangeInt9
;     ; int 9h
; pushf
; call dword test 

; jmp $

; test:
;     iret

; ChangeInt9:
;     mov ax, 0
;     mov es, ax

;     mov ax, word [es:9*4]
;     push ax
;     pop word [OrgInt9]
;     ; mov ax, word [OrgInt9]
;     ; pop ax
;     mov ax, word [es:9*4+2]
;     push ax
;     ; mov ax, word [OrgInt9+2]
;     ; pop ax
;     pop word [OrgInt9+2]

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

;         pushf
;         ; pop bx
;         ; and bh, 11111100b
;         ; push bx
;         ; popf
;         call dword [OrgInt9]

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

; color db 5fh
; OrgInt9 dw 0,0

; times 510-($-$$) db 0
; dw 0aa55h

org 0x7c00
start:
    push cs
    pop ds
    mov ax,0
    mov es,ax
    mov si,in9
    mov di,204h
    mov cx,in9end-in9
    cld
    rep movsb
    
    ; push word [es:9*4];
    ; pop  [es:200h];
    ; push [es:9*4+2];
    ; pop [es:202h]
    mov ax, word [es:9*4]
    push ax
    pop word [es:200h]
    ; mov ax, word [OrgInt9]
    ; pop ax
    mov ax, word [es:9*4+2]
    push ax
    ; mov ax, word [OrgInt9+2]
    ; pop ax
    pop word [es:202h]

    cli
    mov word [es:9*4],204h
    mov word [es:9*4+2],0
    sti

    jmp $

                        ;�鰵��銝剜鱏靘讠�讠�摰䂿緵
in9:
    push ax
    push bx
    push cx
    push es

    in al,60h               ;隞�60蝡臬藁霂餃�𡝗㺭�旿
    
    pushf
    call dword [cs:200h]        ;靚��鍂���䔉��銝剜鱏靘讠��
    
    cmp al,9eh
    jne in9ret

    mov ax,0b800h               ;憒���𨀣𠹭撘�鈭��𦵑�䠷睸嚗屸����遬蝷箏�典�誩�閧��𦵑��
    mov es,ax
    mov bx,0
    mov cx,2000
s:
    mov byte [es:bx],'A'
    add bx,2
    loop s
in9ret:
    pop es
    pop cx
    pop bx
    pop ax
    iret
in9end:nop

times 510-($-$$) db 0
dw 0aa55h