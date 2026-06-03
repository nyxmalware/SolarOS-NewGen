; SolarOS Initrix (второй этап загрузки)
org 0x0000
bits 16

start:
    mov ax, cs
    mov ds, ax
    mov es, ax
    
    mov [boot_drive], dl

    mov si, msg_init
    call print

    call disk_params
    ; НЕ ОБЪЯВЛЯЙ sectors_per_track и heads здесь - они в fat12.asm

    mov si, kernel_filename
    mov ax, KERNEL_SEGMENT
    mov bx, KERNEL_OFFSET
    mov dl, [boot_drive]
    call load_file

    mov ax, KERNEL_SEGMENT
    mov ds, ax
    mov es, ax
    jmp KERNEL_SEGMENT:KERNEL_OFFSET

%include "kernel/print.asm"
%include "disk/disk_params.asm"
%include "disk/read.asm"
%include "disk/fat12.asm"

kernel_filename: db 'KERNEL  BIN'
boot_drive:      db 0

KERNEL_SEGMENT equ 0x2000
KERNEL_OFFSET  equ 0x0000

msg_init: db 'Initrix loaded initializing FAT...', 0x0D, 0x0A, 0
