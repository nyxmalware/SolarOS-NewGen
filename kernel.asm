; SolarOS Kernel v1.0
; 16-бит реальный режим
; точка входа из initrix.asm

org 0x0000
bits 16

start:
    ; настройка сегментов данных
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFF0

    ; сохраняем параметры от загрузчика
    mov [boot_drive], dl

    ; очищаем экран
    mov ax, 0x0003
    int 0x10

    ; выводим заставку
    mov si, logo_solar
    call print

    ; инициализация прерываний
    call init_idt
    call init_irq

    ; инициализация клавиатуры
    call keyboard_init

    ; инициализация мыши (если есть)
    call mouse_init

    ; инициализация видеорежима (графика или текст)
    call vga_init

    ; главный цикл
main_loop:
    mov si, prompt
    call print

    call input_line
    call parse_command

    call print_newline
    jmp main_loop

; включение файлов модулей
%include "kernel/print.asm"
%include "kernel/input.asm"
%include "kernel/idt.asm"
%include "kernel/keyboard.asm"
%include "kernel/commands.asm"

; видеорежим
vga_init:
    pusha
    mov ax, 0x0003    ; текст 80x25
    int 0x10
    popa
    ret

; данные
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

; обработчик ошибок
error_handler:
    call print          ; si уже содержит сообщение об ошибке
    mov ah, 0
    int 0x16            ; ждём нажатие клавиши
    jmp 0xFFFF:0        ; reboot
