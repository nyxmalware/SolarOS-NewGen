; SolarOS print routines

print:
    pusha
    mov ah, 0x0E
.print_loop:
    lodsb
    or al, al
    jz .done
    int 0x10
    jmp .print_loop
.done:
    popa
    ret

print_char:
    pusha
    mov ah, 0x0E
    int 0x10
    popa
    ret

print_newline:
    pusha
    mov al, 0x0D
    call print_char
    mov al, 0x0A
    call print_char
    popa
    ret

print_hex:
    pusha
    mov cx, 4
    mov bx, hex_buffer
    add bx, 4
    mov byte [bx], 0
.hex_loop:
    dec bx
    mov dx, ax
    and dx, 0x000F
    cmp dl, 9
    jle .digit
    add dl, 'A' - '0' - 10
.digit:
    add dl, '0'
    mov [bx], dl
    shr ax, 4
    loop .hex_loop
    mov si, bx
    call print
    popa
    ret

print_dec:
    pusha
    mov bx, 10
    xor cx, cx
    mov di, dec_buffer + 5
    mov byte [di], 0
.div_loop:
    xor dx, dx
    div bx
    add dl, '0'
    dec di
    mov [di], dl
    inc cx
    test ax, ax
    jnz .div_loop
    mov si, di
    call print
    popa
    ret

hex_buffer: db '0000', 0
dec_buffer: db '     ', 0
