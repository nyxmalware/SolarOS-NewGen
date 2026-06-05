; kernel/error.asm - обработчик ошибок для disk/read.asm и disk/fat12.asm
global error_handler

error_handler:
    pusha
    call print_error
    mov ah, 0
    int 0x16
    popa
    jmp 0xFFFF:0

print_error:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_error
.done:
    ret
