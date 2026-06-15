#include "solarios.h"
static void about_draw(window_t *win){
vbe_draw_string(win->x+8,win->y+28,"SolarOS NewGen",COL_BLUE,COL_LTGRAY);
vbe_draw_string(win->x+8,win->y+44,"v0.0.1 Pre-alpha",COL_BLACK,COL_LTGRAY);
vbe_draw_string(win->x+8,win->y+60,"64-bit C + ASM",COL_DKGRAY,COL_LTGRAY);
vbe_draw_string(win->x+8,win->y+76,"PIC/PIT/VBE/FAT32",COL_DKGRAY,COL_LTGRAY);
}
void about_window_create(void){
window_t *win=window_create(220,120,200,100,"About SolarOS");
if(win) win->draw_content=about_draw;
}
