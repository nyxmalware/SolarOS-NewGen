; SolarOS commands with GUI support

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
    db 'desk', 0
    dw cmd_desk
    db 'gui', 0
    dw cmd_desk
    db 0

cmd_desk:
    mov byte [switch_to_gui], 1
    ret

; остальные команды без изменений
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
    call system_shutdown
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

help_text:      
    db 0x0D, 0x0A
    db 'Available commands:', 0x0D, 0x0A
    db '  help     - show this help', 0x0D, 0x0A
    db '  clear    - clear screen', 0x0D, 0x0A
    db '  reboot   - restart system', 0x0D, 0x0A
    db '  shutdown - power off', 0x0D, 0x0A
    db '  desk     - switch to GUI desktop', 0x0D, 0x0A
    db '  mem      - show memory size', 0x0D, 0x0A
    db '  ver      - show version', 0x0D, 0x0A, 0x0D, 0x0A, 0
mem_msg:        db 'Low Memory: ', 0
kb_msg:         db ' KB / 640 KB', 0x0D, 0x0A, 0
shutdown_fail:  db 'Shutdown failed', 0x0D, 0x0A, 0
ver_text:       db 'SolarOS v1.5 (16-bit real mode with GUI)', 0x0D, 0x0A, 0
