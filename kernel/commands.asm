; SolarOS commands

cmd_table:
    db 'help', 0
    dw cmd_help
    db 'clear', 0
    dw cmd_clear
    db 'cls', 0
    dw cmd_clear
    db 'reboot', 0
    dw cmd_reboot
    db 'shutdown', 0
    dw cmd_shutdown
    db 'mem', 0
    dw cmd_mem
    db 'ver', 0
    dw cmd_ver
    db 0

parse_command:
    pusha
    mov si, input_buffer
    call trim
    mov di, cmd_table
.search:
    mov bx, di
    call strcmp
    je .execute
    add di, 3
    cmp byte [di], 0
    jne .search
    jmp .unknown
.execute:
    mov si, [di + 1]
    call si
    jmp .done
.unknown:
    mov si, msg_unknown
    call print
.done:
    popa
    ret

strcmp:
    pusha
    mov cx, 0
.compare:
    mov al, [si + cx]
    mov bl, [bx + cx]
    cmp al, bl
    jne .not_equal
    test al, al
    jz .equal
    inc cx
    jmp .compare
.equal:
    popa
    clc
    ret
.not_equal:
    popa
    stc
    ret

trim:
    pusha
    mov di, si
    mov al, ' '
.skip_spaces:
    cmp byte [si], al
    jne .copy_loop
    inc si
    jmp .skip_spaces
.copy_loop:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    test al, al
    jnz .copy_loop
    popa
    ret

cmd_help:
    mov si, help_text
    call print
    ret

cmd_clear:
    mov ax, 0x0003
    int 0x10
    ret

cmd_reboot:
    jmp 0xFFFF:0

cmd_shutdown:
    mov ax, 0x5301
    xor bx, bx
    int 0x15
    mov ax, 0x530E
    xor bx, bx
    mov cx, 0x0102
    int 0x15
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    mov si, shutdown_fail
    call print
    ret

cmd_mem:
    mov si, mem_msg
    call print
    int 0x12
    call print_dec
    mov si, kb_msg
    call print
    ret

cmd_ver:
    mov si, ver_text
    call print
    ret

msg_unknown:    db 'Unknown command. Type help', 0x0D, 0x0A, 0
help_text:      
    db 0x0D, 0x0A
    db 'Available commands:', 0x0D, 0x0A
    db '  help     - show this help', 0x0D, 0x0A
    db '  clear    - clear screen', 0x0D, 0x0A
    db '  reboot   - restart system', 0x0D, 0x0A
    db '  shutdown - power off', 0x0D, 0x0A
    db '  mem      - show memory size', 0x0D, 0x0A
    db '  ver      - show version', 0x0D, 0x0A, 0x0D, 0x0A, 0
mem_msg:        db 'Low memory: ', 0
kb_msg:         db ' KB / 640 KB', 0x0D, 0x0A, 0
shutdown_fail:  db 'Shutdown failed', 0x0D, 0x0A, 0
ver_text:       db 'SolarOS v1.0 (16-bit real mode)', 0x0D, 0x0A, 0
