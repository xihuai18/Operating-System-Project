org 0e000h

mov ah, 04h
int 21h

int 34h
int 35h
int 36h
int 37h

mov ah, 00h 
int 16h

call re
re:
	int 2bh
