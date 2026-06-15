#include "solarios.h"
static uint8_t ramdisk[1024*1024];
static uint32_t ramdisk_size=0;
static int ramdisk_ready=0;
void fat32_init(void){
    for(int i=0;i<1024*1024;i++) ramdisk[i]=0;
    const char* test_file="test.txt";
    uint8_t* ptr=ramdisk;
    for(int i=0;test_file[i];i++) ptr[i]=test_file[i];
    ptr[8]=0;
    ramdisk_size=1024;
    ramdisk_ready=1;
}
int fat32_read_root_dir(void){
    if(!ramdisk_ready) return -1;
    return 0;
}
int fat32_open(const char *name,uint8_t *buf,uint32_t *size){
    if(!ramdisk_ready||!name||!buf||!size) return -1;
    for(uint32_t i=0;i<ramdisk_size&&i<*size;i++) buf[i]=ramdisk[i];
    *size=ramdisk_size;
    return 0;
}
