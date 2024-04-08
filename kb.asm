org 100h

push 0
pop es
mov ax, [es:36]
mov bx, [es:38]
mov [old_int9], ax
mov [old_int9+2], bx

cli
mov word [es:36], int9
mov [es:38], cs
sti

mov ax, 0
int 10h

lp:
mov ah, 0
int 16h
cmp ah, 1
jne lp

mov ax, [old_int9]
mov bx, [old_int9+2]
mov [es:36], ax
mov [es:38], bx

ret

int9:
  push es
  pusha
  push 0xb800
  pop es
  in  al, 60h
  test al, 128
  jnz end_

  mov di, [cs:cor]
  add di, 2
  mov [cs:cor], di
  mov byte [es:di], 1
end_:
  popa
  pushf
  push cs
  push cont
  jmp far [ds:old_int9]
cont:
  mov byte [es: 1000], 3
  pop es
  iret

cor:
dw 0
counter:
dw 0
old_int9:
dw 0, 0

cycle_array:
    rpointer db 0
    wpointer db 0
    times 10 times 0