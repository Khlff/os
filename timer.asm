org 100h

cli
push 0
pop es
mov word [es:32], int8
mov [es:34], cs
sti

mov ax, 0
int 10h

jmp $

int8:
  pusha
  push es
  push 0xb800
  pop es
  mov ax, [cs:counter]
  inc ax
  and ax, 1
  mov di, [cs:cor]
  add di, 2
  mov [cs:cor], di
  mov byte [es:di], 1
end_:
  mov [cs:counter], ax
  pop es
  mov al, 20h
  out 20h, al
  popa
  iret

cor:
dw 0
counter:
dw 0
