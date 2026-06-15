#include "solarios.h"
static volatile uint8_t kb_buffer[256];
static volatile uint32_t kb_head=0;
static volatile uint32_t kb_tail=0;
static int shift_pressed=0;
static int caps_lock=0;
static const uint8_t scancode_ascii[128]={
0,27,'1','2','3','4','5','6','7','8','9','0','-','=',8,
'\t','q','w','e','r','t','y','u','i','o','p','[',']','\n',
0,'a','s','d','f','g','h','j','k','l',';','\'','`',
0,'\\','z','x','c','v','b','n','m',',','.','/',0,'*',0,' ',
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};
static const uint8_t scancode_shift[128]={
0,27,'!','@','#','$','%','^','&','*','(',')','_','+',8,
'\t','Q','W','E','R','T','Y','U','I','O','P','{','}','\n',
0,'A','S','D','F','G','H','J','K','L',':','"','~',
0,'|','Z','X','C','V','B','N','M','<','>','?',0,'*',0,' ',
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};
void keyboard_init(void){
kb_head=0;
kb_tail=0;
shift_pressed=0;
caps_lock=0;
pic_unmask_irq(1);
}
void keyboard_handler(void){
uint8_t scancode=inb(0x60);
uint8_t released=scancode&0x80;
uint8_t key=scancode&0x7F;
if(key==0x2A||key==0x36){
shift_pressed=!released;
return;
}
if(key==0x3A&&!released){
caps_lock=!caps_lock;
return;
}
if(released) return;
if(key>=128) return;
uint8_t ch;
if(shift_pressed) ch=scancode_shift[key];
else ch=scancode_ascii[key];
if(caps_lock&&ch>='a'&&ch<='z') ch-=32;
else if(caps_lock&&ch>='A'&&ch<='Z') ch+=32;
if(ch){
uint32_t next=(kb_head+1)%256;
if(next!=kb_tail){
kb_buffer[kb_head]=ch;
kb_head=next;
}
}
}
int keyboard_has_char(void){
return kb_head!=kb_tail;
}
char keyboard_get_char(void){
if(kb_head==kb_tail) return 0;
char ch=kb_buffer[kb_tail];
kb_tail=(kb_tail+1)%256;
return ch;
}
