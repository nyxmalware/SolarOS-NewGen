#include "solarios.h"
void pic_init(void){
outb(0x20,0x11);
io_wait();
outb(0xA0,0x11);
io_wait();
outb(0x21,0x20);
io_wait();
outb(0xA1,0x28);
io_wait();
outb(0x21,0x04);
io_wait();
outb(0xA1,0x02);
io_wait();
outb(0x21,0x01);
io_wait();
outb(0xA1,0x01);
io_wait();
outb(0x21,0xFC);
outb(0xA1,0xFF);
}
void pic_send_eoi(uint8_t irq){
if(irq>=8) outb(0xA0,0x20);
outb(0x20,0x20);
}
void pic_mask_irq(uint8_t irq){
uint16_t port;
if(irq<8) port=0x21;
else{port=0xA1;irq-=8;}
uint8_t val=inb(port)|(1<<irq);
outb(port,val);
}
void pic_unmask_irq(uint8_t irq){
uint16_t port;
if(irq<8) port=0x21;
else{port=0xA1;irq-=8;}
uint8_t val=inb(port)&~(1<<irq);
outb(port,val);
}
