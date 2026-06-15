#include "solarios.h"
static uint64_t tick_count=0;
void pit_init(uint32_t freq){
uint16_t divisor=1193180/freq;
if(divisor<1)divisor=1;
if(divisor>65535)divisor=65535;
outb(0x43,0x36);
outb(0x40,divisor&0xFF);
outb(0x40,(divisor>>8)&0xFF);
}
uint64_t pit_get_ticks(void){
return tick_count;
}
void pit_tick(void){
tick_count++;
}
