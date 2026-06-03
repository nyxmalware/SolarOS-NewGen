; SolarOS disk read driver

disk_read:
    push bp
    mov bp, sp
    push bx
    push cx
    push dx
    push di
    push ax

    push cx
    call .lba_to_chs
    pop ax

    mov ah, 0x02
    mov di, 3
.retry:
    pusha
    stc
    int 0x13
    jnc .done
    popa
    call disk_reset
    dec di
    jnz .retry
    jmp read_error
.done:
    popa
    pop ax
    pop di
    pop dx
    pop cx
    pop bx
    pop bp
    ret 4

.lba_to_chs:
    push dx
    push ax
    xor dx, dx
    div word [bp+6]
    inc dx
    mov cx, dx
    xor dx, dx
    div word [bp+4]
    mov dh, dl
    mov ch, al
    shl ah, 6
    or cl, ah
    pop ax
    pop dx
    ret

disk_reset:
    pusha
    mov ah, 0
    int 0x13
    jc read_error
    popa
    ret

read_error:
    mov si, err_read
    jmp error_handler

err_read: db '[!] Disk read error', 0x0D, 0x0A, 0
