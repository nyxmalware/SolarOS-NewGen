ENTRY(_start)
SECTIONS {
. = 0x100000;
.text : {
*(.multiboot2)
*(.text)
}
.rodata : {
*(.rodata*)
}
.data : {
*(.data)
}
.bss : {
*(.bss)
*(COMMON)
}
/DISCARD/ : {
*(.comment)
*(.note*)
}
}
