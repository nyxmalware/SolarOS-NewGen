#include "solarios.h"
static uint32_t fat32_base_lba=0;
static uint32_t fat32_bytes_per_sector=512;
static uint32_t fat32_sectors_per_cluster=0;
static uint32_t fat32_reserved_sectors=0;
static uint32_t fat32_fat_size=0;
static uint32_t fat32_root_cluster=0;
static uint32_t fat32_data_start=0;
void fat32_init(void){
fat32_base_lba=0;
fat32_bytes_per_sector=512;
fat32_sectors_per_cluster=0;
fat32_reserved_sectors=0;
fat32_fat_size=0;
fat32_root_cluster=2;
fat32_data_start=0;
}
int fat32_read_root_dir(void){
return 0;
}
int fat32_open(const char *name,uint8_t *buf,uint32_t *size){
(void)name;(void)buf;(void)size;
return -1;
}
