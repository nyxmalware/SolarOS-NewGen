; SolarOS keyboard driver

scancode_table:
    db 0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0
    db 0, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0
    db 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '`', 0
    db 0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, 0, 0, ' '

keyboard_init:
    pusha
    sti
    popa
    ret

keyboard_handler:
    pusha
    in al, 0x60
    
    cmp al, 0x01
    je .esc_pressed
    
    cmp al, 0x1C
    je .enter_pressed
    
    cmp al, 0x0E
    je .backspace_pressed
    
    cmp al, 0x80
    jae .key_released
    
    mov bx, scancode_table
    xlat
    test al, al
    jz .done
    
    mov ah, 0x0E
    int 0x10
    
.key_released:
    jmp .done
    
.esc_pressed:
    mov si, esc_msg
    call print
    jmp .done
    
.enter_pressed:
    mov al, 0x0D
    mov ah, 0x0E
    int 0x10
    jmp .done
    
.backspace_pressed:
    mov al, 0x08
    mov ah, 0x0E
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    
.done:
    mov al, 0x20
    out 0x20, al
    popa
    iret

esc_msg: db 0x0D, 0x0A, '[ESC] ', 0
