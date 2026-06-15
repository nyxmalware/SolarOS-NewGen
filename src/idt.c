#include "solarios.h"
static struct {
uint16_t offset_low;
uint16_t selector;
uint8_t ist;
uint8_t type_attr;
uint16_t offset_mid;
uint32_t offset_high;
uint32_t reserved;
} __attribute__((packed)) idt_entries[256];
static struct {
uint16_t limit;
uint64_t base;
} __attribute__((packed)) idt_ptr;
extern void *isr_table[256];
void idt_set_gate(uint8_t num,void *handler,uint16_t sel,uint8_t flags){
uint64_t base=(uint64_t)handler;
idt_entries[num].offset_low=base&0xFFFF;
idt_entries[num].offset_mid=(base>>16)&0xFFFF;
idt_entries[num].offset_high=(base>>32)&0xFFFFFFFF;
idt_entries[num].selector=sel;
idt_entries[num].ist=0;
idt_entries[num].type_attr=flags;
idt_entries[num].reserved=0;
}
void idt_init(void){
for(int i=0;i<256;i++){
idt_entries[i].offset_low=0;
idt_entries[i].offset_mid=0;
idt_entries[i].offset_high=0;
idt_entries[i].selector=0;
idt_entries[i].ist=0;
idt_entries[i].type_attr=0;
idt_entries[i].reserved=0;
}
for(int i=0;i<256;i++){
uint64_t addr=(uint64_t)isr_table[i];
idt_set_gate(i,(void*)addr,0x08,0x8E);
}
idt_ptr.limit=sizeof(idt_entries)-1;
idt_ptr.base=(uint64_t)&idt_entries;
__asm__ volatile("lidt %0"::"m"(idt_ptr));
}
