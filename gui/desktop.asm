%include "gui/draw.asm"
%include "gui/start_menu.asm"
%include "gui/icons.asm"
%include "apps/cmd.asm"
%include "apps/calc.asm"
%include "apps/about.asm"

desktop_main:
    pusha
    mov ax, 0x0012
    int 0x10
    call draw_background
    call draw_taskbar
    call draw_all_icons
.main_loop:
    call mouse_get_pos
    cmp word [mouse_click], 1
    jne .main_loop
    cmp bx, 460
    jl .check_icons
    call check_start_button
    jmp .main_loop
.check_icons:
    call check_icon_click
    jmp .main_loop
