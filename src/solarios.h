#ifndef SOLARIOS_H
#define SOLARIOS_H
#include <stdint.h>
#include <stddef.h>
typedef struct {
uint64_t r15,r14,r13,r12,r11,r10,r9,r8;
uint64_t rbp,rdi,rsi,rdx,rcx,rbx,rax;
uint64_t vector;
uint64_t error_code;
uint64_t rip,cs,rflags,rsp,ss;
} interrupt_frame_t;
void gdt_init(void);
void idt_init(void);
void idt_set_gate(uint8_t num,void *handler,uint16_t sel,uint8_t flags);
void pic_init(void);
void pic_send_eoi(uint8_t irq);
void pic_mask_irq(uint8_t irq);
void pic_unmask_irq(uint8_t irq);
void pit_init(uint32_t freq);
uint64_t pit_get_ticks(void);
void pit_tick(void);
void keyboard_init(void);
void keyboard_handler(void);
int keyboard_has_char(void);
char keyboard_get_char(void);
void mouse_init(void);
void mouse_handler(void);
int32_t mouse_get_x(void);
int32_t mouse_get_y(void);
uint8_t mouse_get_buttons(void);
void vbe_init(uint32_t addr,uint32_t pitch,uint32_t width,uint32_t height,uint32_t bpp);
void vbe_put_pixel(uint32_t x,uint32_t y,uint32_t color);
void vbe_fill_rect(uint32_t x,uint32_t y,uint32_t w,uint32_t h,uint32_t color);
void vbe_clear(uint32_t color);
void vbe_draw_char(uint32_t x,uint32_t y,char c,uint32_t fg,uint32_t bg);
void vbe_draw_string(uint32_t x,uint32_t y,const char *s,uint32_t fg,uint32_t bg);
typedef struct window {
int32_t x,y,w,h;
char title[32];
uint32_t title_color;
uint32_t bg_color;
int active;
int visible;
int dragging;
int32_t drag_offx,drag_offy;
void (*draw_content)(struct window *win);
void (*on_click)(struct window *win,int32_t mx,int32_t my);
struct window *next;
} window_t;
void gui_init(void);
void gui_event_loop(void);
void gui_draw_desktop(void);
void gui_draw_taskbar(void);
void gui_draw_start_menu(void);
window_t *window_create(int32_t x,int32_t y,int32_t w,int32_t h,const char *title);
void window_draw(window_t *win);
void window_move(window_t *win,int32_t x,int32_t y);
void window_close(window_t *win);
void window_bring_to_front(window_t *win);
void fat32_init(void);
int fat32_read_root_dir(void);
int fat32_open(const char *name,uint8_t *buf,uint32_t *size);
void shell_init(void);
void shell_run(void);
void shell_process_cmd(const char *cmd);
void calc_window_create(void);
void about_window_create(void);
void *kmalloc(size_t size);
void kfree(void *ptr);
void isr_handler(interrupt_frame_t *frame);
void kprint(const char *str);
void kprint_num(uint64_t num);
void kprint_hex(uint64_t num);
static inline void outb(uint16_t port,uint8_t val){__asm__ volatile("outb %0,%1"::"a"(val),"Nd"(port));}
static inline void outw(uint16_t port,uint16_t val){__asm__ volatile("outw %0,%1"::"a"(val),"Nd"(port));}
static inline void outl(uint16_t port,uint32_t val){__asm__ volatile("outl %0,%1"::"a"(val),"Nd"(port));}
static inline uint8_t inb(uint16_t port){uint8_t r;__asm__ volatile("inb %1,%0":"=a"(r):"Nd"(port));return r;}
static inline uint16_t inw(uint16_t port){uint16_t r;__asm__ volatile("inw %1,%0":"=a"(r):"Nd"(port));return r;}
static inline uint32_t inl(uint16_t port){uint32_t r;__asm__ volatile("inl %1,%0":"=a"(r):"Nd"(port));return r;}
static inline void io_wait(void){outb(0x80,0);}
#define SCREEN_W 640
#define SCREEN_H 480
#define COL_BLACK 0x000000
#define COL_WHITE 0xFFFFFF
#define COL_RED 0xFF0000
#define COL_GREEN 0x00FF00
#define COL_BLUE 0x0000FF
#define COL_GRAY 0x808080
#define COL_DKGRAY 0x404040
#define COL_LTGRAY 0xC0C0C0
#define COL_CYAN 0x00FFFF
#define COL_YELLOW 0xFFFF00
#define COL_ORANGE 0xFF8800
#define COL_TASKBAR 0x0000AA
#define COL_TITLE 0x0000CC
#define COL_DESKTOP 0x808080
#endif
