icon_cmd:   db 'CMD', 0
icon_desk:  db 'DESK', 0
icon_calc:  db 'CALC', 0
icon_about: db 'ABOUT', 0

icon_positions:
    dw 10, 40, icon_cmd, launch_cmd
    dw 90, 40, icon_desk, launch_desk
    dw 170, 40, icon_calc, launch_calc
    dw 250, 40, icon_about, launch_about

draw_all_icons:
    pusha
    mov si, icon_positions
.loop:
    mov ax, [si]
    cmp ax, 0
    je .done
    mov bx, [si+2]
    push si
    call draw_icon
    pop si
    add si, 8
    jmp .loop
.done:
    popa
    ret

check_icon_click:
    pusha
    mov si, icon_positions
.loop:
    mov cx, [si]
    cmp cx, 0
    je .done
    mov dx, [si+2]
    cmp ax, cx
    jl .next
    cmp ax, cx
    jg .next
    add cx, 60
    cmp ax, cx
    jg .next
    cmp bx, dx
    jl .next
    add dx, 40
    cmp bx, dx
    jg .next
    call [si+6]
    jmp .done
.next:
    add si, 8
    jmp .loop
.done:
    popa
    ret
