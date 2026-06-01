; SolarOS input routines

input_line:
    pusha
    mov di, input_buffer
    xor cx, cx
.input_loop:
    mov ah, 0x00
    int 0x16
    cmp al, 0x0D
    je .done
    cmp al, 0x08
    je .backspace
    cmp cl, 63
    je .input_loop
    mov [di], al
    inc di
    inc cx
    mov ah, 0x0E
    int 0x10
    jmp .input_loop
.backspace:
    test cx, cx
    jz .input_loop
    dec di
    dec cx
    mov byte [di], 0
    mov al, 0x08
    call print_char
    mov al, ' '
    call print_char
    mov al, 0x08
    call print_char
    jmp .input_loop
.done:
    mov byte [di], 0
    call print_newline
    popa
    ret

input_buffer: times 64 db 0
