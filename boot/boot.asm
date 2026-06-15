MBALIGN equ 1 << 0
MEMINFO equ 1 << 1
FBREQ equ 1 << 2
FLAGS equ MBALIGN | MEMINFO | FBREQ
MAGIC equ 0xE85250D6
CHECKSUM equ -(MAGIC + FLAGS)
section .multiboot2 align=8
dd MAGIC
dd FLAGS
dd CHECKSUM
dw 0
dw 0
dd 8
framebuffer_tag_start:
dw 5
dw 0
dd 20
dd 640
dd 480
dd 32
framebuffer_tag_end:
section .bss align=4096
p4_table resb 4096
p3_table resb 4096
p2_table resb 4096
stack_bottom resb 16384
stack_top:
section .text
bits 32
global _start
extern long_mode_entry
_start:
mov esp, stack_top
call check_cpuid
call check_long_mode
call setup_page_tables
call enable_paging
lgdt [gdt64.pointer]
jmp gdt64.code_seg:long_mode_entry
check_cpuid:
pushfd
pop eax
mov ecx, eax
xor eax, 1 << 21
push eax
popfd
pushfd
pop eax
push ecx
popfd
cmp eax, ecx
je .no_cpuid
ret
.no_cpuid:
hlt
check_long_mode:
mov eax, 0x80000000
cpuid
cmp eax, 0x80000001
jb .no_long_mode
mov eax, 0x80000001
cpuid
test edx, 1 << 29
jz .no_long_mode
ret
.no_long_mode:
hlt
setup_page_tables:
mov eax, p3_table
or eax, 0b11
mov [p4_table], eax
mov eax, p2_table
or eax, 0b11
mov [p3_table], eax
mov ecx, 0
.map_p2:
mov eax, 0x200000
mul ecx
or eax, 0b10000011
mov [p2_table + ecx * 8], eax
inc ecx
cmp ecx, 512
jne .map_p2
ret
enable_paging:
mov eax, p4_table
mov cr3, eax
mov eax, cr4
or eax, 1 << 5
mov cr4, eax
rdmsr
or eax, 1 << 8
wrmsr
mov eax, cr0
or eax, 1 << 31
mov cr0, eax
ret
section .rodata align=8
gdt64:
dq 0
.code_seg equ $ - gdt64
dq (1<<43) | (1<<44) | (1<<47) | (1<<53)
.data_seg equ $ - gdt64
dq (1<<44) | (1<<47) | (1<<41)
.pointer:
dw $ - gdt64 - 1
dq gdt64
