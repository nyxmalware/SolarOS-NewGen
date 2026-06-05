; kernel/error.asm - обработчик ошибок
global error_handler

error_handler:
    pusha
    call print_string
    mov ah, 0
    int 0x16
    popa
    jmp 0xFFFF:0

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret
