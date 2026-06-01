; SolarOS Kernel v1.1
; 16-бит реальный режим
; точка входа из initrix.asm

org 0x0000
bits 16

start:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFF0

    mov [boot_drive], dl

    mov ax, 0x0003
    int 0x10

    mov si, logo_solar
    call print

    call init_idt
    call init_irq
    call keyboard_init
    call setup_keyboard_int

main_loop:
    mov si, prompt
    call print
    call input_line
    call parse_command
    call print_newline
    jmp main_loop

%include "kernel/print.asm"
%include "kernel/input.asm"
%include "kernel/commands.asm"
%include "kernel/idt.asm"
%include "kernel/keyboard.asm"
%include "disk/read.asm"
%include "disk/disk_params.asm"
%include "disk/fat12.asm"

setup_mouse_int:
    pusha
    cli
    mov word [0x2C], mouse_handler
    mov word [0x2E], 0x0000
    sti
    popa
    ret

setup_keyboard_int:
    pusha
    cli
    mov word [0x24], keyboard_handler
    mov word [0x26], 0x0000
    sti
    popa
    ret

error_handler:
    call print
    mov ah, 0
    int 0x16
    jmp 0xFFFF:0

boot_drive:    db 0
prompt:        db 'SolarOS@User >> ', 0

logo_solar:    
    db 0x0D, 0x0A
    db '   SSS   OOO   L       AAA    RRR    OOO   SSS  ', 0x0D, 0x0A
    db '  S     O   O  L      A   A   R   R  O   O  S    ', 0x0D, 0x0A
    db '   SSS  O   O  L      AAAAA   RRR    O   O   SSS ', 0x0D, 0x0A
    db '      S O   O  L      A   A   R  R   O   O     S ', 0x0D, 0x0A
    db '  SSS   OOO   LLLLL  A   A   R   R   OOO   SSS   ', 0x0D, 0x0A
    db 0x0D, 0x0A, 'SolarOS v1.0 (C) 2026', 0x0D, 0x0A, 0x0D, 0x0A, 0
