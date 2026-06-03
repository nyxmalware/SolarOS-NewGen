load_file:
    push ax bx cx dx si di es

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

; ... остальной код ...

; данные (без двоеточий)
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

