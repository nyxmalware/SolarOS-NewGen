#include "solarios.h"
static int32_t mouse_x=320;
static int32_t mouse_y=240;
static uint8_t mouse_buttons=0;
static uint8_t mouse_cycle=0;
static int8_t mouse_byte[3];
static int mouse_ready=0;
void mouse_wait(uint8_t type){
uint32_t timeout=100000;
if(type==0){
while(timeout--){
if((inb(0x64)&1)==1) return;
}
} else {
while(timeout--){
if((inb(0x64)&2)==0) return;
}
}
}
void mouse_write(uint8_t val){
mouse_wait(1);
outb(0x64,0xD4);
mouse_wait(1);
outb(0x60,val);
}
uint8_t mouse_read(void){
mouse_wait(0);
return inb(0x60);
}
void mouse_init(void){
uint8_t status;
mouse_wait(1);
outb(0x64,0xA8);
mouse_wait(1);
outb(0x64,0x20);
status=mouse_read();
status|=2;
status&=~0x20;
mouse_wait(1);
outb(0x64,0x60);
mouse_wait(1);
outb(0x60,status);
mouse_write(0xF6);
mouse_read();
mouse_write(0xF4);
mouse_read();
mouse_x=320;
mouse_y=240;
mouse_buttons=0;
mouse_cycle=0;
mouse_ready=1;
pic_unmask_irq(12);
}
void mouse_handler(void){
if(!mouse_ready) return;
uint8_t data=inb(0x60);
mouse_byte[mouse_cycle]=data;
mouse_cycle++;
if(mouse_cycle>=3){
mouse_cycle=0;
if(mouse_byte[0]&0x80||mouse_byte[0]&0x40) return;
int8_t dx=mouse_byte[1];
int8_t dy=mouse_byte[2];
mouse_buttons=mouse_byte[0]&0x07;
mouse_x+=dx;
mouse_y-=dy;
if(mouse_x<0)mouse_x=0;
if(mouse_x>=SCREEN_W)mouse_x=SCREEN_W-1;
if(mouse_y<0)mouse_y=0;
if(mouse_y>=SCREEN_H)mouse_y=SCREEN_H-1;
}
}
int32_t mouse_get_x(void){return mouse_x;}
int32_t mouse_get_y(void){return mouse_y;}
uint8_t mouse_get_buttons(void){return mouse_buttons;}
