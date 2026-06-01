; оконный менеджер

struc WINDOW
    .x      resw 1
    .y      resw 1
    .w      resw 1
    .h      resw 1
    .title  resw 1
    .active resb 1
    .next   resw 1
endstruc

windows_list dw 0
window_count dw 0

create_window:
    pusha
    mov ax, WINDOW_size
    call malloc
    mov di, ax
    
    mov word [di + WINDOW.x], 100
    mov word [di + WINDOW.y], 100
    mov word [di + WINDOW.w], 200
    mov word [di + WINDOW.h], 150
    mov word [di + WINDOW.title], si
    mov byte [di + WINDOW.active], 1
    mov word [di + WINDOW.next], 0
    
    mov ax, [windows_list]
    cmp ax, 0
    je .first
    mov bx, ax
.find_last:
    mov bx, [bx + WINDOW.next]
    cmp bx, 0
    jne .find_last
    mov [bx + WINDOW.next], di
    jmp .done
.first:
    mov [windows_list], di
.done:
    inc word [window_count]
    call draw_window
    popa
    ret

draw_window:
    pusha
    mov di, [windows_list]
.draw_loop:
    cmp di, 0
    je .done
    
    ; рамка окна
    mov ax, [di + WINDOW.x]
    mov bx, [di + WINDOW.y]
    mov cx, [di + WINDOW.w]
    add cx, ax
    mov dx, [di + WINDOW.h]
    add dx, bx
    mov bl, 0x0F
    call rect_outline
    
    ; заголовок
    mov ax, [di + WINDOW.x]
    add ax, 2
    mov bx, [di + WINDOW.y]
    add bx, 2
    mov si, [di + WINDOW.title]
    call draw_string
    
    ; кнопка закрытия
    mov ax, [di + WINDOW.x]
    add ax, [di + WINDOW.w]
    sub ax, 12
    mov bx, [di + WINDOW.y]
    add bx, 2
    mov cx, 10
    mov dx, 10
    mov bl, 0x04
    call rect_fill
    
    mov ax, [di + WINDOW.x]
    add ax, [di + WINDOW.w]
    sub ax, 9
    mov bx, [di + WINDOW.y]
    add bx, 5
    mov si, close_str
    call draw_string
    
    mov di, [di + WINDOW.next]
    jmp .draw_loop
.done:
    popa
    ret

close_str: db 'X', 0

close_window:
    pusha
    cmp di, 0
    je .done
    
    ; удаление окна из списка
    mov bx, [windows_list]
    cmp bx, di
    je .remove_first
    
.prev:
    cmp [bx + WINDOW.next], di
    je .remove
    mov bx, [bx + WINDOW.next]
    cmp bx, 0
    jne .prev
    jmp .done
    
.remove:
    mov ax, [di + WINDOW.next]
    mov [bx + WINDOW.next], ax
    jmp .free
    
.remove_first:
    mov ax, [di + WINDOW.next]
    mov [windows_list], ax
    
.free:
    call free
    dec word [window_count]
    call repaint_desktop
    
.done:
    popa
    ret

check_windows_click:
    pusha
    mov di, [windows_list]
.check_loop:
    cmp di, 0
    je .done
    
    mov cx, [di + WINDOW.x]
    mov dx, [di + WINDOW.y]
    
    ; проверка клика по кнопке закрытия
    mov si, cx
    add si, [di + WINDOW.w]
    sub si, 12
    cmp ax, si
    jl .check_window
    cmp ax, si
    jg .check_window
    add si, 10
    cmp ax, si
    jg .check_window
    cmp bx, dx
    jl .check_window
    add dx, 2
    cmp bx, dx
    jg .check_window
    add dx, 10
    cmp bx, dx
    jg .check_window
    
    call close_window
    jmp .done
    
.check_window:
    mov cx, [di + WINDOW.x]
    mov dx, [di + WINDOW.y]
    cmp ax, cx
    jl .next
    add cx, [di + WINDOW.w]
    cmp ax, cx
    jg .next
    cmp bx, dx
    jl .next
    add dx, 20
    cmp bx, dx
    jg .next
    
    call move_window
    
.next:
    mov di, [di + WINDOW.next]
    jmp .check_loop
.done:
    popa
    ret

move_window:
    pusha
    mov cx, ax
    mov dx, bx
    sub cx, [di + WINDOW.x]
    sub dx, [di + WINDOW.y]
    
.wait:
    call mouse_get_pos
    cmp word [mouse_click], 1
    je .wait
    
    mov ax, [mouse_x]
    sub ax, cx
    mov [di + WINDOW.x], ax
    mov ax, [mouse_y]
    sub ax, dx
    mov [di + WINDOW.y], ax
    
    call repaint_desktop
    popa
    ret
