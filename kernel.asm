; SolarOS Kernel v2.0
; 16-бит реальный режим

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
    call mouse_init
    call setup_mouse_int
    
    call rust_init

    call check_boot_mode

main_loop:
    mov si, prompt
    call print
    call input_line
    call parse_command
    call print_newline
    
    cmp byte [switch_to_gui], 1
    je launch_gui
    
    jmp main_loop

launch_gui:
    mov byte [switch_to_gui], 0
    call desktop_main
    jmp main_loop

check_boot_mode:
    pusha
    mov si, boot_param
    call strlen
    cmp ax, 0
    je .done
    mov si, boot_param
    mov di, gui_str
    call strcmp
    jnc .set_gui
    jmp .done
.set_gui:
    mov byte [switch_to_gui], 1
.done:
    popa
    ret

%include "kernel/print.asm"
%include "kernel/input.asm"
%include "kernel/commands.asm"
%include "kernel/idt.asm"
%include "kernel/keyboard.asm"

%include "lib/string.asm"
%include "lib/math.asm"

%include "drivers/vga.asm"
%include "drivers/mouse.asm"
%include "drivers/font.asm"

%include "gui/desktop.asm"
%include "gui/start_menu.asm"
%include "gui/taskbar.asm"
%include "gui/icons.asm"
%include "gui/window.asm"
%include "gui/cursor.asm"
%include "gui/events.asm"
%include "gui/draw.asm"

%include "apps/cmd.asm"
%include "apps/calc.asm"
%include "apps/about.asm"

setup_keyboard_int:
    pusha
    cli
    mov word [0x24], keyboard_handler
    mov word [0x26], 0x0000
    sti
    popa
    ret

setup_mouse_int:
    pusha
    cli
    mov word [0x2C], mouse_handler
    mov word [0x2E], 0x0000
    sti
    popa
    ret

error_handler:
    call print
    mov ah, 0
    int 0x16
    jmp 0xFFFF:0

system_shutdown:
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
    ret

system_reboot:
    jmp 0xFFFF:0

exit_to_cmd:
    mov ax, 0x0003
    int 0x10
    ret

repaint_desktop:
    call draw_background
    call draw_taskbar
    call draw_all_icons
    ret

draw_background:
    pusha
    mov ax, 0
    mov bx, 0
    mov cx, 640
    mov dx, 480
    mov bl, 0x01
    call rect_fill
    popa
    ret

; rust extern
extern rust_init
extern rust_strlen
extern rust_strcmp

boot_drive:      db 0
switch_to_gui:   db 0
prompt:          db 'SolarOS@User:~$ ', 0
boot_param:      times 64 db 0
gui_str:         db 'gui', 0

logo_solar:    
    db 0x0D, 0x0A
    db '   SSS   OOO   L       AAA    RRR    OOO   SSS   ', 0x0D, 0x0A
    db '  S     O   O  L      A   A   R   R  O   O  S     ', 0x0D, 0x0A
    db '   SSS  O   O  L      AAAAA   RRR    O   O   SSS  ', 0x0D, 0x0A
    db '      S O   O  L      A   A   R  R   O   O     S  ', 0x0D, 0x0A
    db '  SSS   OOO   LLLLL  A   A   R   R   OOO   SSS    ', 0x0D, 0x0A
    db 0x0D, 0x0A, 'SolarOS v2.0 (C) 2026', 0x0D, 0x0A, 0x0D, 0x0A, 0
