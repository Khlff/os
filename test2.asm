org 100h

xor ax, ax
int 10h
push 0xb800
pop es
mov bh, 7h
mov bl, 52h
mov [es:2], bx  
int 16h

int 20h