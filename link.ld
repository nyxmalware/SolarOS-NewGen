/* SolarOS Linker Script */
ENTRY(_start)

SECTIONS {
    /* Загрузка ядра по адресу 0x2000:0x0000 = 0x20000 */
    . = 0x20000;
    
    .text : {
        *(.text)
        *(.text.*)
    }
    
    .rodata : {
        *(.rodata)
        *(.rodata.*)
    }
    
    .data : {
        *(.data)
        *(.data.*)
    }
    
    .bss : {
        *(.bss)
        *(.bss.*)
        *(COMMON)
    }
    
    /* Удаляем лишние секции */
    /DISCARD/ : {
        *(.eh_frame)
        *(.comment)
        *(.note)
        *(.note.*)
    }
}
