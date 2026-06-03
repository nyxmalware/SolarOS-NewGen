org 0x7C00
bits 16

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [boot_drive], dl

    mov ax, 0x0003
    int 0x10

    mov si, msg_loading
    call print

    mov ax, 0x1000
    mov es, ax
    xor bx, bx
    mov al, 2
    mov cl, 2
    mov ch, 0
    mov dh, 0
    mov dl, [boot_drive]
    mov ah, 0x02
    int 0x13
    jc disk_error

    mov dl, [boot_drive]
    jmp 0x1000:0x0000

print:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print
.done:
    ret

disk_error:
    mov si, msg_disk_error
    call print
    mov ah, 0
    int 0x16
    jmp 0xFFFF:0

boot_drive:     db 0
msg_loading:    db 'SolarOS loading...', 0x0D, 0x0A, 0
msg_disk_error: db 'Disk error! Press any key to reboot.', 0

times 510 - ($ - $$) db 0
dw 0xAA55
