
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