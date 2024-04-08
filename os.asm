org 7c00h

interrupts:
  mov word[0x80], int20
  mov word[0x82], 0
  mov word[0x9c], int27
  mov word[0x9e], 0

first_clean:
  mov ah, 0 ; очистка экрана
  mov al, 0 ; очистка экрана
  int 10h ; 10h: Видео сервис.

  push dx
  mov ah, 02h ; убираем курсор
  mov dh, 25
  int 10h
  pop dx

read:
  mov ax, 201h ;02H читать секторы; AL = число секторов
  mov dh, 0 ;номер головки чтения/записи
  mov cx, 2h ;CH = номер дорожки (цилиндра)(0-n) CL = номер сектора (1-n)
  push 50h
  pop es  
  mov bx, 0 ;ES:BX => адрес буфера вызывающей программы пишем 500
  int 13h ;дисковый ввод вывод

jmp ret_adr

clean:
  mov ah, 0 ; очистка экрана
  mov al, 0 ; очистка экрана
  int 10h ; 10h: Видео сервис.

  push dx
  mov ah, 02h ; убираем курсор
  mov dh, 25
  int 10h
  pop dx

change_cl_file:
  mov bl, 10
  xor ax, ax
  mov al, [selected_line]
  mul bl
  add al, 3
  mov cl, al

mov ax, 20Ah
mov dh, 0
mov dl, 0
mov ch, 0
push 0x90
pop es
mov bx, 0x100
int 13h


push 0
pop ds


mov ax, 0x90

mov fs, ax
mov ss, ax
mov gs, ax
mov ds, ax

xor ax, ax
mov bx, ax
mov cx, ax
mov dx, ax
mov si, ax
mov di, ax
mov sp, ax
mov bp, ax

mov word[ds:0], 0x20cd
push sp

push 0x90
push 0x100
retf


ret_adr:
  selected_line db 0 ; Номер выбранной строки, начиная с 0
  
paint:
  mov ah, 0
  mov al, 0
  int 10h

  push dx
  mov dh, 25
  mov ah, 2
  int 10h
  pop dx

  mov cx, 512 ; сколько байт нужн считать раз (loop 512)
  push 0
  pop ds ; номер сектора
  mov si, 500h ; смещение внутри сегмента
  push 0xb800 ; номер сегмента видеорежима
  pop es  ; PS Нельзя класть мовом в сегментные регистры
  mov di, 0 ; смещение внутри видеопамяти

  xor bx, bx ; номер для подсчёта слов
  xor dl, dl
  lodsb

  prep_begin:
    inc bx
    cmp dl, [selected_line] ; Сравниваем текущую строку с выбранной
    jne paint_offset
    jmp paint_arrow

  paint_arrow:
    mov ah, 09h          ; Атрибут для стрелочки
    mov al, 10h          ; Символ стрелочки
    stosw                ; Выводим стрелочку в видеопамять
    dec si
    jmp print

  paint_offset:
    mov ah, 08h         ; Атрибут для символа офсета
    mov al, 7h          ; Символ офсета
    stosw               ; Выводим символ в видеопамять
    dec si
    jmp print

  print:
    lodsb  ; lodsb выгружает один байт с адреса ds si
    cmp al, 0
    je print_zero

    mov ah, 03h  ; Восстанавливаем атрибут текста
    stosw ; записывает в видеорежим по адресу es di
    inc bx
    loop print

  print_zero:
    push ax
    mov ax, 40 ; 40 ширина строки
    sub ax, bx ; 40 - длина текущего текста
    shl ax, 1 ; сдвиг влево так как знакоместо весит 2 байта
    add di, ax ; увеличение смещение внутри видеопамяти
    pop ax

    xor bx, bx
    inc dx
    dec cx ; loop не сделал уменьшаем сами 512 - 1

  lp_zero:
    lodsb
    cmp al, 0
    jne prep_begin
    loop lp_zero

waiting:
    xor ah, ah
    int 16h ; BIOS - KEYBOARD - GET KEYSTROKE
    cmp ah, 0x48 ; проверяем, была ли нажата клавиша ВВЕРХ
    je up_b
    cmp ah, 0x50 ; проверяем, была ли нажата клавиша ВНИЗ
    je down_b
    cmp ah, 0x1c
    je enter_b
    jmp waiting

up_b:
  cmp [selected_line], 0 ; проверка то что в самом верху
  je paint
  dec byte [selected_line] ; Уменьшаем номер выбранной строки
  jmp paint

down_b:
  cmp byte [selected_line], dl ; проверка то что в самом низу
  je paint
  inc byte [selected_line] ; Увеличиваем номер выбранной строки
  jmp paint

enter_b:
  jmp clean

seg:
  dw 0x90

int27:
  add dx, 15
  shr dx, 4
  add [seg], dx

int20:
  push 0
  pop ds
  push 0
  pop es
  jmp paint

jmp 500h ; весит два байта поэтому снизу 510 а не 512
times 510-($-$$) db 0 ; добивает весь сектор до 512 
db 0x55, 0xaa ; последние два байта должны быть такими хз почему