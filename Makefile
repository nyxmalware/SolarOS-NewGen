CC=gcc
LD=ld
NASM=nasm
CFLAGS=-ffreestanding -nostdlib -nostdinc -fno-builtin -fno-stack-protector -nostartfiles -nodefaultlibs -mgeneral-regs-only -mno-red-zone -mcmodel=kernel -Isrc -Wall -Wextra
LDFLAGS=-T linker.ld -nostdlib
ASMFLAGS=-f elf64
SRCDIR=src
BOOTDIR=boot
OBJDIR=build
C_SRCS=$(wildcard $(SRCDIR)/*.c)
ASM_SRCS=$(wildcard $(SRCDIR)/*.asm) $(BOOTDIR)/boot.asm $(BOOTDIR)/long_mode.asm
C_OBJS=$(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(C_SRCS))
ASM_OBJS=$(patsubst $(SRCDIR)/%.asm,$(OBJDIR)/%.o,$(wildcard $(SRCDIR)/*.asm))
BOOT_OBJ=$(OBJDIR)/boot.o $(OBJDIR)/long_mode.o
OBJS=$(BOOT_OBJ) $(ASM_OBJS) $(C_OBJS)
all: $(OBJDIR)/solarios.bin $(OBJDIR)/solarios.iso $(OBJDIR)/solarios.img
$(OBJDIR):
mkdir -p $(OBJDIR)
$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
$(CC) $(CFLAGS) -c $< -o $@
$(OBJDIR)/%.o: $(SRCDIR)/%.asm | $(OBJDIR)
$(NASM) $(ASMFLAGS) $< -o $@
$(OBJDIR)/boot.o: $(BOOTDIR)/boot.asm | $(OBJDIR)
$(NASM) $(ASMFLAGS) $< -o $@
$(OBJDIR)/long_mode.o: $(BOOTDIR)/long_mode.asm | $(OBJDIR)
$(NASM) $(ASMFLAGS) $< -o $@
$(OBJDIR)/solarios.elf: $(OBJS) linker.ld
$(LD) $(LDFLAGS) -o $@ $(OBJS)
$(OBJDIR)/solarios.bin: $(OBJDIR)/solarios.elf
objcopy -O binary $< $@
$(OBJDIR)/solarios.img: $(OBJDIR)/solarios.bin
dd if=/dev/zero of=$@ bs=512 count=2880
dd if=$< of=$@ bs=512 seek=1 conv=notrunc
$(OBJDIR)/solarios.iso: $(OBJDIR)/solarios.elf
mkdir -p iso/boot/grub
cp $< iso/boot/solarios.elf
echo 'set timeout=0' > iso/boot/grub/grub.cfg
echo 'set default=0' >> iso/boot/grub/grub.cfg
echo 'menuentry "SolarOS NewGen" {' >> iso/boot/grub/grub.cfg
echo '  multiboot2 /boot/solarios.elf' >> iso/boot/grub/grub.cfg
echo '}' >> iso/boot/grub/grub.cfg
grub-mkrescue -o $@ iso 2>/dev/null || grub2-mkrescue -o $@ iso 2>/dev/null || echo "ISO needs grub-mkrescue"
clean:
rm -rf $(OBJDIR) iso
.PHONY: all clean
