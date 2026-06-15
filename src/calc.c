#include "solarios.h"
static char calc_expr[64];
static int calc_pos=0;
static int64_t calc_result=0;
static int calc_has_result=0;
static int calc_error=0;
static void calc_draw(window_t *win){
    vbe_draw_string(win->x+8,win->y+28,"SolarOS Calc",COL_BLACK,COL_LTGRAY);
    if(calc_error){
        vbe_draw_string(win->x+8,win->y+48,"ERROR",COL_RED,COL_LTGRAY);
    } else if(calc_has_result){
        char buf[32];
        int64_t r=calc_result;
        int neg=0;
        if(r<0){neg=1;r=-r;}
        int i=0;
        if(r==0) buf[i++]='0';
        else while(r>0){buf[i++]='0'+(r%10);r/=10;}
        char out[32];
        int p=0;
        if(neg) out[p++]='-';
        for(int j=i-1;j>=0;j--) out[p++]=buf[j];
        out[p]=0;
        vbe_draw_string(win->x+8,win->y+48,out,COL_BLACK,COL_LTGRAY);
    } else {
        vbe_draw_string(win->x+8,win->y+48,calc_expr[0]?calc_expr:"0",COL_BLACK,COL_LTGRAY);
    }
    vbe_draw_string(win->x+8,win->y+70,"Type: + - * / | C clear",COL_DKGRAY,COL_LTGRAY);
}
static void calc_on_key(struct window *win,char ch){
    (void)win;
    if(calc_error){
        if(ch=='c'||ch=='C') calc_error=0;
        else return;
    }
    if(ch=='\n'){
        int64_t a=0,b=0;
        char op=0;
        int p=0;
        while(calc_expr[p]==' '&&calc_expr[p]) p++;
        int neg=0;
        if(calc_expr[p]=='-'){neg=1;p++;}
        while(calc_expr[p]>='0'&&calc_expr[p]<='9'){
            a=a*10+(calc_expr[p]-'0');
            p++;
        }
        if(neg)a=-a;
        while(calc_expr[p]==' '&&calc_expr[p]) p++;
        if(calc_expr[p]=='+'||calc_expr[p]=='-'||calc_expr[p]=='*'||calc_expr[p]=='/'){
            op=calc_expr[p];
            p++;
        }
        while(calc_expr[p]==' '&&calc_expr[p]) p++;
        neg=0;
        if(calc_expr[p]=='-'){neg=1;p++;}
        while(calc_expr[p]>='0'&&calc_expr[p]<='9'){
            b=b*10+(calc_expr[p]-'0');
            p++;
        }
        if(neg)b=-b;
        switch(op){
            case '+':calc_result=a+b;break;
            case '-':calc_result=a-b;break;
            case '*':calc_result=a*b;break;
            case '/':
                if(b!=0) calc_result=a/b;
                else {calc_error=1;calc_has_result=0;calc_expr[0]=0;calc_pos=0;return;}
                break;
            default:calc_result=a;break;
        }
        calc_has_result=1;
        calc_error=0;
    } else if(ch==8){
        if(calc_pos>0) calc_expr[--calc_pos]=0;
        calc_has_result=0;
        calc_error=0;
    } else if(ch=='c'||ch=='C'){
        calc_pos=0;
        calc_expr[0]=0;
        calc_has_result=0;
        calc_result=0;
        calc_error=0;
    } else if(calc_pos<62&&ch>=' '&&ch<='~'){
        calc_expr[calc_pos++]=ch;
        calc_expr[calc_pos]=0;
        calc_has_result=0;
        calc_error=0;
    }
}
void calc_window_create(void){
    window_t *win=window_create(200,100,260,120,"Calculator");
    if(win){
        win->draw_content=calc_draw;
        win->on_key=calc_on_key;
        calc_pos=0;
        calc_expr[0]=0;
        calc_has_result=0;
        calc_result=0;
        calc_error=0;
    }
}
