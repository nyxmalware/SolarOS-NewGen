#include "solarios.h"

static uint32_t fat32_partition_lba = 0;
static uint32_t fat32_bytes_per_sector = 512;
static uint32_t fat32_sectors_per_cluster = 0;
static uint32_t fat32_reserved_sectors = 0;
static uint32_t fat32_fat_size = 0;
static uint32_t fat32_root_cluster = 0;
static uint32_t fat32_data_start = 0;
static uint32_t fat32_fat_start = 0;

static int fat32_read_sector(uint32_t lba, uint8_t *buf) {
    for (int i = 0; i < 3; i++) {
        __asm__ volatile (
            "mov $0x42, %%ah\n"
            "mov $0x80, %%dl\n"
            "mov %0, %%rsi\n"
            "int $0x13\n"
            : : "r"(lba), "r"(buf)
            : "%ah", "%dl", "%rsi"
        );
    }
    return 0;
}

void fat32_init(void) {
    uint8_t bpb[512];
    fat32_partition_lba = 0;
    fat32_read_sector(fat32_partition_lba, bpb);
    
    if (bpb[0x1FE] != 0x55 || bpb[0x1FF] != 0xAA) return;
    
    fat32_bytes_per_sector = *(uint16_t*)(bpb + 0x0B);
    fat32_sectors_per_cluster = bpb[0x0D];
    fat32_reserved_sectors = *(uint16_t*)(bpb + 0x0E);
    fat32_fat_size = *(uint32_t*)(bpb + 0x24);
    fat32_root_cluster = *(uint32_t*)(bpb + 0x2C);
    
    fat32_fat_start = fat32_partition_lba + fat32_reserved_sectors;
    fat32_data_start = fat32_fat_start + (fat32_fat_size * 2);
}

static uint32_t fat32_next_cluster(uint32_t cluster) {
    uint32_t fat_offset = cluster * 4;
    uint32_t fat_sector = fat32_fat_start + (fat_offset / fat32_bytes_per_sector);
    uint32_t fat_offset_in_sector = fat_offset % fat32_bytes_per_sector;
    uint8_t sector[512];
    fat32_read_sector(fat_sector, sector);
    return *(uint32_t*)(sector + fat_offset_in_sector) & 0x0FFFFFFF;
}

static void fat32_read_cluster(uint32_t cluster, uint8_t *buf) {
    uint32_t lba = fat32_data_start + (cluster - 2) * fat32_sectors_per_cluster;
    for (uint32_t i = 0; i < fat32_sectors_per_cluster; i++) {
        fat32_read_sector(lba + i, buf + i * 512);
    }
}

int fat32_open(const char *name, uint8_t *buf, uint32_t *size) {
    uint32_t current_cluster = fat32_root_cluster;
    
    while (current_cluster >= 2 && current_cluster < 0x0FFFFFF8) {
        uint8_t cluster_data[fat32_sectors_per_cluster * 512];
        fat32_read_cluster(current_cluster, cluster_data);
        
        for (uint32_t i = 0; i < (fat32_sectors_per_cluster * 512); i += 32) {
            uint8_t *entry = cluster_data + i;
            if (entry[0] == 0x00) break;
            if (entry[0] == 0xE5) continue;
            
            char entry_name[12];
            for (int j = 0; j < 8; j++) {
                if (entry[j] == ' ') break;
                entry_name[j] = entry[j];
            }
            entry_name[8] = '.';
            for (int j = 0; j < 3; j++) {
                if (entry[8 + j] == ' ') break;
                entry_name[9 + j] = entry[8 + j];
            }
            entry_name[11] = 0;
            
            if (entry_name[0] == '.') continue;
            
            for (int j = 0; name[j]; j++) {
                if (name[j] >= 'a' && name[j] <= 'z') {
                    if (entry_name[j] != name[j] - 32) goto next;
                } else {
                    if (entry_name[j] != name[j]) goto next;
                }
            }
            
            uint32_t file_cluster = *(uint32_t*)(entry + 0x1A);
            uint32_t file_size = *(uint32_t*)(entry + 0x1C);
            *size = file_size;
            
            uint32_t bytes_read = 0;
            while (file_cluster >= 2 && file_cluster < 0x0FFFFFF8 && bytes_read < file_size) {
                uint8_t cluster_data[fat32_sectors_per_cluster * 512];
                fat32_read_cluster(file_cluster, cluster_data);
                uint32_t to_copy = fat32_sectors_per_cluster * 512;
                if (bytes_read + to_copy > file_size) to_copy = file_size - bytes_read;
                for (uint32_t j = 0; j < to_copy; j++) buf[bytes_read + j] = cluster_data[j];
                bytes_read += to_copy;
                file_cluster = fat32_next_cluster(file_cluster);
            }
            return 0;
            next:;
        }
        current_cluster = fat32_next_cluster(current_cluster);
    }
    return -1;
}

int fat32_read_root_dir(void) {
    uint32_t current_cluster = fat32_root_cluster;
    while (current_cluster >= 2 && current_cluster < 0x0FFFFFF8) {
        uint8_t cluster_data[fat32_sectors_per_cluster * 512];
        fat32_read_cluster(current_cluster, cluster_data);
        for (uint32_t i = 0; i < (fat32_sectors_per_cluster * 512); i += 32) {
            uint8_t *entry = cluster_data + i;
            if (entry[0] == 0x00) break;
            if (entry[0] == 0xE5) continue;
            if ((entry[0xB] & 0x08) == 0) {
                char name[12];
                for (int j = 0; j < 8; j++) {
                    if (entry[j] == ' ') break;
                    name[j] = entry[j];
                }
                name[8] = '.';
                for (int j = 0; j < 3; j++) {
                    if (entry[8 + j] == ' ') break;
                    name[9 + j] = entry[8 + j];
                }
                name[11] = 0;
                vbe_draw_string(8, 200 + i * 2, name, COL_WHITE, COL_BLACK);
            }
        }
        current_cluster = fat32_next_cluster(current_cluster);
    }
    return 0;
}
