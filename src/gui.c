#include "solarios.h"
static window_t *windows=NULL;
static window_t *active_window=NULL;
static int start_menu_open=0;
int gui_mode=1;
window_t *window_create(int32_t x,int32_t y,int32_t w,int32_t h,const char *title){
window_t *win=(window_t*)kmalloc(sizeof(window_t));
if(!win) return NULL;
win->x=x;
win->y=y;
win->w=w;
win->h=h;
win->title_color=COL_TITLE;
win->bg_color=COL_LTGRAY;
win->active=1;
win->visible=1;
win->dragging=0;
win->drag_offx=0;
win->drag_offy=0;
win->draw_content=NULL;
win->on_click=NULL;
for(int i=0;i<31&&title[i];i++) win->title[i]=title[i];
win->title[31]=0;
win->next=windows;
windows=win;
active_window=win;
return win;
}
void window_draw(window_t *win){
if(!win||!win->visible) return;
vbe_fill_rect(win->x,win->y,win->w,win->h,COL_LTGRAY);
vbe_fill_rect(win->x,win->y,win->w,20,win->active?COL_TITLE:COL_DKGRAY);
vbe_draw_string(win->x+4,win->y+6,win->title,COL_WHITE,win->active?COL_TITLE:COL_DKGRAY);
vbe_fill_rect(win->x+win->w-18,win->y+2,16,16,COL_RED);
vbe_draw_char(win->x+win->w-14,win->y+4,'X',COL_WHITE,COL_RED);
vbe_fill_rect(win->x+1,win->y+20,win->w-2,win->h-21,win->bg_color);
if(win->draw_content) win->draw_content(win);
}
void window_move(window_t *win,int32_t x,int32_t y){
if(!win) return;
if(x<0)x=0;
if(y<0)y=0;
if(x+win->w>SCREEN_W)x=SCREEN_W-win->w;
if(y+win->h>SCREEN_H-32)y=SCREEN_H-32-win->h;
win->x=x;
win->y=y;
}
void window_close(window_t *win){
if(!win) return;
win->visible=0;
if(active_window==win) active_window=NULL;
}
void window_bring_to_front(window_t *win){
if(!win) return;
if(windows==win) return;
window_t *prev=NULL;
window_t *cur=windows;
while(cur){
if(cur==win){
if(prev) prev->next=cur->next;
break;
}
prev=cur;
cur=cur->next;
}
if(cur){
cur->next=windows;
windows=cur;
}
window_t *w=windows;
while(w){
w->active=(w==win);
w=w->next;
}
active_window=win;
}
static void draw_icon(uint32_t x,uint32_t y,const char *label,uint32_t color){
vbe_fill_rect(x,y,48,48,color);
vbe_fill_rect(x+2,y+2,44,44,COL_WHITE);
vbe_fill_rect(x+4,y+4,40,40,color);
vbe_draw_string(x+4,y+54,label,COL_WHITE,COL_DESKTOP);
}
void gui_draw_desktop(void){
vbe_clear(COL_DESKTOP);
draw_icon(40,40,"Calc",COL_BLUE);
draw_icon(40,130,"About",COL_GREEN);
draw_icon(40,220,"Exit",COL_RED);
}
void gui_draw_taskbar(void){
vbe_fill_rect(0,SCREEN_H-32,SCREEN_W,32,COL_TASKBAR);
vbe_fill_rect(4,SCREEN_H-28,60,24,COL_DKGRAY);
vbe_draw_string(10,SCREEN_H-22,"Start",COL_WHITE,COL_DKGRAY);
char timebuf[16];
uint64_t secs=pit_get_ticks()/100;
uint64_t mins=secs/60;
secs=secs%60;
uint64_t hrs=(mins/60)%24;
mins=mins%60;
timebuf[0]='0'+(hrs/10);
timebuf[1]='0'+(hrs%10);
timebuf[2]=':';
timebuf[3]='0'+(mins/10);
timebuf[4]='0'+(mins%10);
timebuf[5]=':';
timebuf[6]='0'+(secs/10);
timebuf[7]='0'+(secs%10);
timebuf[8]=0;
vbe_draw_string(SCREEN_W-80,SCREEN_H-22,timebuf,COL_WHITE,COL_TASKBAR);
if(start_menu_open){
vbe_fill_rect(0,SCREEN_H-200,120,168,COL_LTGRAY);
vbe_fill_rect(0,SCREEN_H-200,120,168,COL_DKGRAY);
vbe_fill_rect(2,SCREEN_H-198,116,164,COL_LTGRAY);
vbe_draw_string(8,SCREEN_H-190,"Reboot",COL_BLACK,COL_LTGRAY);
vbe_draw_string(8,SCREEN_H-170,"Shutdown",COL_BLACK,COL_LTGRAY);
vbe_draw_string(8,SCREEN_H-150,"-> CMD",COL_BLACK,COL_LTGRAY);
}
}
void gui_draw_start_menu(void){
start_menu_open=!start_menu_open;
}
static window_t *find_window_at(int32_t mx,int32_t my){
window_t *win=windows;
while(win){
if(win->visible&&mx>=win->x&&mx<win->x+win->w&&my>=win->y&&my<win->y+win->h)
return win;
win=win->next;
}
return NULL;
}
static void process_mouse_click(int32_t mx,int32_t my,uint8_t btn){
if(!(btn&1)) return;
if(my>=SCREEN_H-32){
if(mx>=4&&mx<=64&&my>=SCREEN_H-28&&my<=SCREEN_H-4){
gui_draw_start_menu();
return;
}
if(start_menu_open){
if(mx<120&&my>=SCREEN_H-200){
int32_t cy=my-(SCREEN_H-200);
if(cy>=8&&cy<24){
outb(0x64,0xFE);
}
if(cy>=28&&cy<44){
while(1) __asm__ volatile("hlt");
}
if(cy>=48&&cy<64){
gui_mode=0;
start_menu_open=0;
}
}
}
return;
}
start_menu_open=0;
if(mx<100&&my<280){
if(my>=40&&my<100){
calc_window_create();
return;
}
if(my>=130&&my<190){
about_window_create();
return;
}
if(my>=220&&my<280){
gui_mode=0;
start_menu_open=0;
return;
}
}
window_t *win=find_window_at(mx,my);
if(win){
window_bring_to_front(win);
if(my>=win->y&&my<win->y+20){
if(mx>=win->x+win->w-18&&mx<win->x+win->w-2&&my>=win->y+2&&my<win->y+18){
window_close(win);
return;
}
win->dragging=1;
win->drag_offx=mx-win->x;
win->drag_offy=my-win->y;
}
if(win->on_click) win->on_click(win,mx,my);
}
}
static void process_mouse_move(int32_t mx,int32_t my){
window_t *win=windows;
while(win){
if(win->dragging&&win==active_window){
window_move(win,mx-win->drag_offx,my-win->drag_offy);
break;
}
win=win->next;
}
}
static void process_mouse_release(void){
window_t *win=windows;
while(win){
win->dragging=0;
win=win->next;
}
}
void gui_redraw(void){
gui_draw_desktop();
window_t *w=windows;
window_t *stack[32];
int count=0;
while(w&&count<32){
if(w->visible) stack[count++]=w;
w=w->next;
}
for(int i=count-1;i>=0;i--){
window_draw(stack[i]);
}
gui_draw_taskbar();
int32_t mx=mouse_get_x();
int32_t my=mouse_get_y();
vbe_fill_rect(mx,my,8,8,COL_WHITE);
vbe_fill_rect(mx+1,my+1,6,6,COL_BLACK);
}
void gui_init(void){
gui_mode=1;
start_menu_open=0;
windows=NULL;
active_window=NULL;
gui_draw_desktop();
gui_draw_taskbar();
}
void gui_event_loop(void){
static uint8_t prev_btn=0;
while(gui_mode){
uint8_t btn=mouse_get_buttons();
int32_t mx=mouse_get_x();
int32_t my=mouse_get_y();
if((btn&1)&&!(prev_btn&1)){
process_mouse_click(mx,my,btn);
}
if(btn&1) process_mouse_move(mx,my);
if(!(btn&1)&&(prev_btn&1)){
process_mouse_release();
}
prev_btn=btn;
gui_redraw();
for(volatile int i=0;i<100000;i++);
}
}
