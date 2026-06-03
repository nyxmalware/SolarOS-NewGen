; SolarOS FAT12 driver

load_file:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov [file_segment], ax
    mov [file_offset], bx
    mov [drive_num], dl
    mov [filename_ptr], si

    call fat_init
    call read_root_dir

    mov ax, [first_cluster]
    mov [current_cluster], ax

    mov bx, [file_offset]
    mov es, [file_segment]

.load_loop:
    mov ax, [current_cluster]
    call cluster_to_lba
    mov cl, [sectors_per_cluster]
    mov dl, [drive_num]
    push word [sectors_per_track]
    push word [heads]
    call disk_read

    mov al, [sectors_per_cluster]
    mul word [bytes_per_sector]
    add bx, ax
    jnc .no_seg_inc
    mov ax, es
    add ax, 0x1000
    mov es, ax
    xor bx, bx

.no_seg_inc:
    call get_next_cluster
    mov [current_cluster], ax
    cmp ax, 0x0FF8
    jb .load_loop

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

fat_init:
    push es
    xor ax, ax
    mov es, ax

    mov ax, [es:0x7C00 + 11]
    mov [bytes_per_sector], ax
    mov al, [es:0x7C00 + 13]
    mov [sectors_per_cluster], al
    mov ax, [es:0x7C00 + 14]
    mov [reserved_sectors], ax
    mov al, [es:0x7C00 + 16]
    mov [fat_count], al
    mov ax, [es:0x7C00 + 17]
    mov [dir_entries], ax
    mov ax, [es:0x7C00 + 22]
    mov [sectors_per_fat], ax
    mov ax, [es:0x7C00 + 24]
    mov [sectors_per_track], ax
    mov ax, [es:0x7C00 + 26]
    mov [heads], ax
    pop es

    mov ax, [sectors_per_fat]
    mov bl, [fat_count]
    xor bh, bh
    mul bx
    add ax, [reserved_sectors]
    mov [root_dir_lba], ax

    mov ax, [dir_entries]
    shl ax, 5
    xor dx, dx
    div word [bytes_per_sector]
    or dx, dx
    jz .no_round
    inc ax
.no_round:
    mov [root_dir_size], al
    add ax, [root_dir_lba]
    mov [data_lba], ax
    ret

read_root_dir:
    mov ax, [root_dir_lba]
    mov cl, [root_dir_size]
    mov dl, [drive_num]
    mov bx, 0x7E00
    push word [sectors_per_track]
    push word [heads]
    call disk_read

    mov bx, 0
    mov di, 0x7E00
.search:
    mov si, [filename_ptr]
    mov cx, 11
    push di
    repe cmpsb
    pop di
    je .found
    add di, 32
    inc bx
    cmp bx, [dir_entries]
    jl .search
    mov si, err_file_not_found
    jmp error_handler
.found:
    mov ax, [di + 26]
    mov [first_cluster], ax
    ret

get_next_cluster:
    push bx
    push cx
    push dx
    push si
    mov ax, [current_cluster]
    mov cx, 3
    mul cx
    mov cx, 2
    div cx
    mov si, 0x8000
    add si, ax
    mov ax, [ds:si]
    or dx, dx
    jz .even
    shr ax, 4
    jmp .done
.even:
    and ax, 0x0FFF
.done:
    pop si
    pop dx
    pop cx
    pop bx
    ret

cluster_to_lba:
    sub ax, 2
    xor ah, ah
    mul byte [sectors_per_cluster]
    add ax, [data_lba]
    ret

; данные
bytes_per_sector    dw 0
sectors_per_cluster db 0
reserved_sectors    dw 0
fat_count           db 0
dir_entries         dw 0
sectors_per_fat     dw 0
sectors_per_track   dw 0
heads               dw 0
drive_num           db 0
root_dir_lba        dw 0
root_dir_size       db 0
data_lba            dw 0
current_cluster     dw 0
first_cluster       dw 0
filename_ptr        dw 0
file_segment        dw 0
file_offset         dw 0

err_file_not_found: db '[!] File not found', 0x0D, 0x0A, 0
