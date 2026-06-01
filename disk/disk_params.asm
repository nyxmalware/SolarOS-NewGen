; SolarOS disk parameters

disk_params:
    push ax es

    push es
    mov ah, 0x08
    int 0x13
    jc read_error
    pop es

    and cl, 0x3F
    xor ch, ch
    inc dh

    pop es ax
    ret
