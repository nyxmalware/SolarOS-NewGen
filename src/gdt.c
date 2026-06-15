#include "solarios.h"
static uint8_t gdt_entries[3*8];
static struct {
uint16_t limit;
uint64_t base;
} __attribute__((packed)) gdt_ptr;
static void gdt_set_gate(uint8_t num,uint32_t base,uint32_t limit,uint8_t access,uint8_t gran){
gdt_entries[num*8]=limit&0xFF;
gdt_entries[num*8+1]=(limit>>8)&0xFF;
gdt_entries[num*8+2]=base&0xFF;
gdt_entries[num*8+3]=(base>>8)&0xFF;
gdt_entries[num*8+4]=(base>>16)&0xFF;
gdt_entries[num*8+5]=access;
gdt_entries[num*8+6]=((gran&0x0F)<<4)|((limit>>16)&0x0F);
gdt_entries[num*8+7]=(base>>24)&0xFF;
}
void gdt_init(void){
for(int i=0;i<3*8;i++) gdt_entries[i]=0;
gdt_set_gate(0,0,0,0,0);
gdt_set_gate(1,0,0xFFFFF,0x9A,0xA);
gdt_set_gate(2,0,0xFFFFF,0x92,0xA);
gdt_ptr.limit=3*8-1;
gdt_ptr.base=(uint64_t)&gdt_entries;
__asm__ volatile("lgdt %0"::"m"(gdt_ptr));
__asm__ volatile(
"mov $0x10,%%ax\n"
"mov %%ax,%%ds\n"
"mov %%ax,%%es\n"
"mov %%ax,%%fs\n"
"mov %%ax,%%gs\n"
"mov %%ax,%%ss\n"
:::"ax"
);
}
