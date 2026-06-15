#include "solarios.h"
extern int gui_mode;
static char cmd_buf[256];
static int cmd_pos=0;
static uint32_t shell_x=8;
static uint32_t shell_y=8;
static int in_gui=1;
static void shell_print(const char *s){
vbe_draw_string(shell_x,shell_y,s,COL_WHITE,COL_BLACK);
shell_y+=12;
if(shell_y>=SCREEN_H-44){
vbe_clear(COL_BLACK);
shell_y=8;
}
}
static void shell_prompt(void){
shell_print("solar> ");
}
void shell_init(void){
cmd_pos=0;
shell_x=8;
shell_y=8;
}
void shell_process_cmd(const char *cmd){
if(cmd[0]==0) return;
if(cmd[0]=='h'&&cmd[1]=='e'&&cmd[2]=='l'&&cmd[3]=='p'&&cmd[4]==0){
shell_print("SolarOS NewGen 0.0.1");
shell_print("Commands:");
shell_print("  help  - this text");
shell_print("  clear - clear screen");
shell_print("  reboot- restart");
shell_print("  mem   - memory info");
shell_print("  gui   - start GUI");
shell_print("  calc  - calculator");
shell_print("  about - about system");
return;
}
if(cmd[0]=='c'&&cmd[1]=='l'&&cmd[2]=='e'&&cmd[3]=='a'&&cmd[4]=='r'){
vbe_clear(COL_BLACK);
shell_y=8;
return;
}
if(cmd[0]=='r'&&cmd[1]=='e'&&cmd[2]=='b'&&cmd[3]=='o'&&cmd[4]=='o'&&cmd[5]=='t'){
outb(0x64,0xFE);
return;
}
if(cmd[0]=='s'&&cmd[1]=='h'&&cmd[2]=='u'&&cmd[3]=='t'&&cmd[4]=='d'&&cmd[5]=='o'&&cmd[6]=='w'&&cmd[7]=='n'){
while(1)__asm__ volatile("hlt");
return;
}
if(cmd[0]=='m'&&cmd[1]=='e'&&cmd[2]=='m'){
shell_print("Heap: 4MB bump");
return;
}
if(cmd[0]=='g'&&cmd[1]=='u'&&cmd[2]=='i'){
in_gui=1;
gui_mode=1;
gui_init();
gui_event_loop();
vbe_clear(COL_BLACK);
shell_y=8;
shell_print("Returned to CMD");
return;
}
if(cmd[0]=='c'&&cmd[1]=='a'&&cmd[2]=='l'&&cmd[3]=='c'){
in_gui=1;
gui_mode=1;
gui_init();
calc_window_create();
gui_event_loop();
vbe_clear(COL_BLACK);
shell_y=8;
return;
}
if(cmd[0]=='a'&&cmd[1]=='b'&&cmd[2]=='o'&&cmd[3]=='u'&&cmd[4]=='t'){
in_gui=1;
gui_mode=1;
gui_init();
about_window_create();
gui_event_loop();
vbe_clear(COL_BLACK);
shell_y=8;
return;
}
shell_print("Unknown command");
}
void shell_run(void){
vbe_clear(COL_BLACK);
shell_y=8;
shell_print("SolarOS NewGen 0.0.1 Pre-alpha");
shell_print("Type 'help' for commands");
shell_prompt();
cmd_pos=0;
while(1){
if(keyboard_has_char()){
char ch=keyboard_get_char();
if(ch=='\n'){
cmd_buf[cmd_pos]=0;
shell_print(cmd_buf);
shell_process_cmd(cmd_buf);
cmd_pos=0;
shell_prompt();
} else if(ch==8){
if(cmd_pos>0){
cmd_pos--;
vbe_draw_char(shell_x+cmd_pos*8,shell_y,' ',COL_WHITE,COL_BLACK);
}
} else if(cmd_pos<254&&ch>=0x20){
cmd_buf[cmd_pos++]=ch;
vbe_draw_char(shell_x+(cmd_pos-1)*8,shell_y,ch,COL_WHITE,COL_BLACK);
}
}
}
}
