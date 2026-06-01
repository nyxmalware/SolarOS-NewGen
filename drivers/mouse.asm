; SolarOS PS/2 mouse driver

mouse_init:
    pusha
    call mouse_wait_write
    mov al, 0xD4
    out 0x64, al
    call mouse_wait_write
    mov al, 0xF4
    out 0x60, al
    call mouse_wait_read
    in al, 0x60
    cmp al, 0xFA
    jne .fail
    mov byte [mouse_present], 1
.fail:
    popa
    ret

mouse_wait_write:
    push ax
    in al, 0x64
    test al, 2
    jnz mouse_wait_write
    pop ax
    ret

mouse_wait_read:
    push ax
    in al, 0x64
    test al, 1
    jz mouse_wait_read
    pop ax
    ret

mouse_handler:
    pusha
    in al, 0x60
    mov bl, [mouse_byte_count]
    cmp bl, 0
    je .byte1
    cmp bl, 1
    je .byte2
    cmp bl, 2
    je .byte3
    mov byte [mouse_byte_count], 0
    jmp .done

.byte1:
    mov [mouse_flags], al
    inc byte [mouse_byte_count]
    jmp .done

.byte2:
    movsx bx, al
    add [mouse_x], bx
    inc byte [mouse_byte_count]
    jmp .done

.byte3:
    movsx bx, al
    sub [mouse_y], bx
    mov byte [mouse_byte_count], 0
    call mouse_draw

.done:
    mov al, 0x20
    out 0x20, al
    popa
    iret

mouse_draw:
    pusha
    cmp byte [mouse_visible], 1
    jne .skip
    mov ax, [mouse_x]
    mov bx, [mouse_y]
    mov si, mouse_cursor
    call draw_cursor
.skip:
    popa
    ret

mouse_show:
    mov byte [mouse_visible], 1
    call mouse_draw
    ret

mouse_hide:
    mov byte [mouse_visible], 0
    ret

draw_cursor:
    pusha
    mov cx, 16
    mov di, si
.row_loop:
    push cx
    mov cx, 16
.col_loop:
    lodsb
    test al, al
    jz .no_pixel
    call vga_set_pixel
.no_pixel:
    inc ax
    loop .col_loop
    mov ax, [mouse_x]
    inc bx
    pop cx
    loop .row_loop
    popa
    ret

mouse_present:   db 0
mouse_visible:   db 1
mouse_flags:     db 0
mouse_byte_count: db 0
mouse_x:         dw 160
mouse_y:         dw 120
mouse_cursor:
    db 1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0
    db 1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0
    db 1,0,1,1,1,1,1,1,0,1,0,0,0,0,0,0
    db 1,0,1,0,0,0,0,1,0,1,0,0,0,0,0,0
    db 1,0,1,0,0,0,0,1,0,1,0,0,0,0,0,0
    db 1,0,1,0,0,0,0,1,0,1,0,0,0,0,0,0
    db 1,0,1,1,1,1,1,1,0,1,0,0,0,0,0,0
    db 1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0
    db 1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0
    db 1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0
    db 1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0
    db 1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0
    db 1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
