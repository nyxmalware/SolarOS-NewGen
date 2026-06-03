; SolarOS VGA graphics driver

VGA_WIDTH equ 640
VGA_HEIGHT equ 480
VGA_MEMORY equ 0xA0000

vga_init:
    pusha
    mov ax, 0x0013
    int 0x10
    popa
    ret

vga_text_mode:
    pusha
    mov ax, 0x0003
    int 0x10
    popa
    ret

vga_set_pixel:
    pusha
    mov cx, VGA_WIDTH
    mul cx
    add ax, bx
    mov di, ax
    mov al, dl
    mov [VGA_MEMORY + di], al
    popa
    ret

vga_get_pixel:
    pusha
    mov cx, VGA_WIDTH
    mul cx
    add ax, bx
    mov si, ax
    mov al, [VGA_MEMORY + si]
    mov [.pixel], al
    popa
    mov al, [.pixel]
    ret
.pixel: db 0

vga_draw_line:
    pusha
    cmp ax, cx
    je .vertical
    jb .x_swap
.x_swap:
    xchg ax, cx
    xchg bx, dx
.x_loop:
    pusha
    call .line_calc
    mov dl, 0x0F
    call vga_set_pixel
    inc ax
    cmp ax, cx
    jle .x_loop
    jmp .done
.vertical:
    cmp bx, dx
    jbe .y_loop
    xchg bx, dx
.y_loop:
    pusha
    mov dl, 0x0F
    call vga_set_pixel
    inc bx
    cmp bx, dx
    jle .y_loop
.done:
    popa
    ret

.line_calc:
    pusha
    mov si, cx
    sub si, ax
    mov di, dx
    sub di, bx
    cmp si, di
    jg .steep
    xchg si, di
.steep:
    mov cx, si
    mov dx, di
    popa
    ret

vga_rect:
    pusha
    push ax
    push bx
    push cx
    push dx
    mov si, cx
    sub si, ax
.rect_loop:
    push ax
    push bx
    call vga_draw_line
    pop bx
    pop ax
    inc bx
    cmp bx, dx
    jle .rect_loop
    pop dx
    pop cx
    pop bx
    pop ax
    popa
    ret

vga_clear:
    pusha
    mov cx, VGA_WIDTH * VGA_HEIGHT
    mov di, VGA_MEMORY
    mov al, 0
    rep stosb
    popa
    ret

vga_draw_char:
    pusha
    push ax
    push bx
    mov si, font_8x16
    mov al, cl
    mov cl, 16
    mul cl
    add si, ax
    pop bx
    pop ax
    mov cx, 16
.char_loop:
    push cx
    mov cl, 8
    mov dl, [si]
    call vga_draw_char_line
    inc si
    inc bx
    pop cx
    loop .char_loop
    popa
    ret

vga_draw_char_line:
    pusha
    mov cx, 8
.char_line_loop:
    test dl, 0x80
    jz .no_pixel
    pusha
    mov dl, 0x0F
    call vga_set_pixel
    popa
.no_pixel:
    shl dl, 1
    inc ax
    loop .char_line_loop
    popa
    ret

vga_draw_string:
    pusha
    mov bp, si
.string_loop:
    mov cl, [bp]
    test cl, cl
    jz .done
    call vga_draw_char
    add ax, 8
    inc bp
    jmp .string_loop
.done:
    popa
    ret

font_8x16:
    times 4096 db 0
