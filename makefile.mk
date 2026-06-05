# SolarOS Makefile
NASM = nasm
LD = ld
QEMU = qemu-system-x86_64
BUILD_DIR = build
IMG = solaros.img

ASM_FLAGS = -f elf32
LD_FLAGS = -m elf_i386 -Ttext 0x1000 --oformat binary

ASM_SOURCES = \
	kernel.asm \
	initrix.asm \
	disk/read.asm \
	disk/fat12.asm \
	disk/disk_params.asm \
	kernel/print.asm \
	kernel/input.asm \
	kernel/commands.asm \
	kernel/idt.asm \
	kernel/keyboard.asm \
	kernel/error.asm \
	lib/string.asm \
	lib/math.asm \
	drivers/vga.asm \
	drivers/mouse.asm \
	drivers/font.asm \
	gui/desktop.asm \
	gui/start_menu.asm \
	gui/taskbar.asm \
	gui/icons.asm \
	gui/window.asm \
	gui/cursor.asm \
	gui/events.asm \
	gui/draw.asm \
	apps/cmd.asm \
	apps/calc.asm \
	apps/about.asm

ASM_OBJECTS = $(addprefix $(BUILD_DIR)/, $(notdir $(ASM_SOURCES:.asm=.o)))

.PHONY: all clean run

all: $(BUILD_DIR) $(BUILD_DIR)/boot.bin $(BUILD_DIR)/initrix.bin $(ASM_OBJECTS) $(BUILD_DIR)/kernel.bin $(IMG)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/boot.bin: boot.asm
	$(NASM) -f bin boot.asm -o $(BUILD_DIR)/boot.bin

$(BUILD_DIR)/initrix.bin: initrix.asm
	$(NASM) -f bin initrix.asm -o $(BUILD_DIR)/initrix.bin

$(BUILD_DIR)/%.o: %.asm
	$(NASM) $(ASM_FLAGS) $< -o $@

$(BUILD_DIR)/%.o: disk/%.asm
	$(NASM) $(ASM_FLAGS) $< -o $@

$(BUILD_DIR)/%.o: kernel/%.asm
	$(NASM) $(ASM_FLAGS) $< -o $@

$(BUILD_DIR)/%.o: lib/%.asm
	$(NASM) $(ASM_FLAGS) $< -o $@

$(BUILD_DIR)/%.o: drivers/%.asm
	$(NASM) $(ASM_FLAGS) $< -o $@

$(BUILD_DIR)/%.o: gui/%.asm
	$(NASM) $(ASM_FLAGS) $< -o $@

$(BUILD_DIR)/%.o: apps/%.asm
	$(NASM) $(ASM_FLAGS) $< -o $@

$(BUILD_DIR)/kernel.bin: $(ASM_OBJECTS)
	$(LD) $(LD_FLAGS) -o $@ $^

$(IMG): $(BUILD_DIR)/boot.bin $(BUILD_DIR)/initrix.bin $(BUILD_DIR)/kernel.bin
	dd if=/dev/zero of=$(IMG) bs=512 count=2880 status=none
	dd if=$(BUILD_DIR)/boot.bin of=$(IMG) conv=notrunc status=none
	dd if=$(BUILD_DIR)/initrix.bin of=$(IMG) seek=2 conv=notrunc status=none
	dd if=$(BUILD_DIR)/kernel.bin of=$(IMG) seek=4 conv=notrunc status=none
	@echo "SolarOS build complete"

run: $(IMG)
	$(QEMU) -fda $(IMG)

clean:
	rm -rf $(BUILD_DIR) $(IMG)
