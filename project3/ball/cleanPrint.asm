org 9600h
printnames equ 9200h
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