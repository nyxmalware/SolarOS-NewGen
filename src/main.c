#include "solarios.h"
static uint8_t heap[0x400000];
static uint32_t heap_offset=0;
void *kmalloc(size_t size){
size=(size+15)&~15;
if(heap_offset+size>=sizeof(heap)) return NULL;
void *ptr=&heap[heap_offset];
heap_offset+=size;
return ptr;
}
void kfree(void *ptr){
(void)ptr;
}
void kprint(const char *str){
while(*str){
if(*str=='\n'){
outb(0x3F8,'\r');
outb(0x3F8,'\n');
} else {
outb(0x3F8,*str);
}
str++;
}
}
void kprint_num(uint64_t num){
if(num==0){kprint("0");return;}
char buf[21];
int i=0;
while(num>0){
buf[i++]='0'+(num%10);
num/=10;
}
buf[i]=0;
char rev[21];
for(int j=0;j<i;j++) rev[j]=buf[i-1-j];
rev[i]=0;
kprint(rev);
}
void kprint_hex(uint64_t num){
kprint("0x");
char hex[]="0123456789ABCDEF";
char buf[17];
for(int i=15;i>=0;i--){
buf[15-i]=hex[(num>>(i*4))&0xF];
}
buf[16]=0;
kprint(buf);
}
void isr_handler(interrupt_frame_t *frame){
switch(frame->vector){
case 32:
pit_tick();
pic_send_eoi(0);
break;
case 33:
keyboard_handler();
pic_send_eoi(1);
break;
case 44:
mouse_handler();
pic_send_eoi(12);
break;
default:
if(frame->vector<32){
kprint("EXCEPTION: ");
kprint_num(frame->vector);
kprint("\n");
for(;;) __asm__ volatile("hlt");
}
if(frame->vector>=32&&frame->vector<48)
pic_send_eoi(frame->vector-32);
break;
}
}
static uint32_t parse_mb2_fb(uint32_t mb2_addr){
uint32_t *p=(uint32_t*)(uint64_t)mb2_addr;
uint32_t total_size=p[0];
uint32_t offset=8;
while(offset<total_size){
uint32_t tag_type=p[offset/4];
uint32_t tag_size=p[offset/4+1];
if(tag_type==0) break;
if(tag_type==8){
uint32_t fb_addr_val=p[offset/4+2];
uint32_t fb_pitch_val=p[offset/4+3];
uint32_t fb_width_val=p[offset/4+4];
uint32_t fb_height_val=p[offset/4+5];
uint32_t fb_bpp_val=p[offset/4+6];
vbe_init(fb_addr_val,fb_pitch_val,fb_width_val,fb_height_val,fb_bpp_val);
return 1;
}
offset+=(tag_size+7)&~7;
}
return 0;
}
void kmain(uint32_t mb2_magic,uint32_t mb2_addr){
if(mb2_magic!=0x36D76289){
kprint("Bad multiboot2 magic\n");
for(;;)__asm__ volatile("hlt");
}
gdt_init();
idt_init();
pic_init();
pit_init(100);
keyboard_init();
mouse_init();
parse_mb2_fb(mb2_addr);
fat32_init();
__asm__ volatile("sti");
kprint("SolarOS NewGen 0.0.1 Pre-alpha\n");
kprint("GDT OK | IDT OK | PIC OK | PIT 100Hz OK\n");
kprint("Keyboard OK | Mouse OK | VBE OK\n");
shell_init();
shell_run();
}
