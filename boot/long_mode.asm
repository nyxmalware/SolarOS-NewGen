section .text bits 64
extern kmain
global long_mode_entry
long_mode_entry:
mov ax, 0x10
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax
mov rsp, 0x90000
call kmain
.halt:
hlt
jmp .halt
