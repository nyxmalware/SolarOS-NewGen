# SolarOS Makefile - исправленная версия с kernel.asm в корне

NASM = nasm
LD = ld
QEMU = qemu-system-x86_64
CARGO = cargo

BUILD_DIR = build
RUST_DIR = rust

ASM_FLAGS = -f elf32
LD_FLAGS = -m elf_i386 -T link.ld
QEMU_FLAGS = -drive file=$(BUILD_DIR)/solaros.img,format=raw,if=floppy

ASM_SOURCES = \
	boot.asm \
	initrix.asm \
	kernel.asm \
	disk/disk_params.asm \
	disk/fat12.asm \
	disk/read.asm \
	drivers/mouse.asm \
	drivers/vga.asm \
	drivers/font.asm \
	gui/cursor.asm \
	gui/desktop.asm \
	gui/draw.asm \
	gui/events.asm \
	gui/icons.asm \
	gui/start_menu.asm \
	gui/taskbar.asm \
	gui/window.asm \
	kernel/commands.asm \
	kernel/idt.asm \
	kernel/input.asm \
	kernel/keyboard.asm \
	kernel/print.asm \
	lib/math.asm \
	lib/string.asm \
	apps/about.asm \
	apps/calc.asm \
	apps/cmd.asm

ASM_OBJECTS = $(addprefix $(BUILD_DIR)/, $(notdir $(ASM_SOURCES:.asm=.o)))

.PHONY: all clean build_asm build_rust link build_img run

all: build_asm build_rust link build_img

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

build_asm: $(BUILD_DIR) $(ASM_OBJECTS)

$(BUILD_DIR)/%.o: %.asm
	$(NASM) $(ASM_FLAGS) $< -o $@

$(BUILD_DIR)/%.o: disk/%.asm
	$(NASM) $(ASM_FLAGS) $< -o $@

$(BUILD_DIR)/%.o: drivers/%.asm
	$(NASM) $(ASM_FLAGS) $< -o $@

$(BUILD_DIR)/%.o: gui/%.asm
	$(NASM) $(ASM_FLAGS) $< -o $@

$(BUILD_DIR)/%.o: kernel/%.asm
	$(NASM) $(ASM_FLAGS) $< -o $@

$(BUILD_DIR)/%.o: lib/%.asm
	$(NASM) $(ASM_FLAGS) $< -o $@

$(BUILD_DIR)/%.o: apps/%.asm
	$(NASM) $(ASM_FLAGS) $< -o $@

build_rust:
	cd $(RUST_DIR) && $(CARGO) build --release --target i686-unknown-linux-gnu
	cp $(RUST_DIR)/target/i686-unknown-linux-gnu/release/libsolaros_rust.a $(BUILD_DIR)/

link: $(BUILD_DIR)
	$(LD) $(LD_FLAGS) -o $(BUILD_DIR)/solaros.bin \
		$(BUILD_DIR)/boot.o \
		$(BUILD_DIR)/initrix.o \
		$(BUILD_DIR)/kernel.o \
		$(BUILD_DIR)/disk_params.o \
		$(BUILD_DIR)/fat12.o \
		$(BUILD_DIR)/read.o \
		$(BUILD_DIR)/mouse.o \
		$(BUILD_DIR)/vga.o \
		$(BUILD_DIR)/font.o \
		$(BUILD_DIR)/cursor.o \
		$(BUILD_DIR)/desktop.o \
		$(BUILD_DIR)/draw.o \
		$(BUILD_DIR)/events.o \
		$(BUILD_DIR)/icons.o \
		$(BUILD_DIR)/start_menu.o \
		$(BUILD_DIR)/taskbar.o \
		$(BUILD_DIR)/window.o \
		$(BUILD_DIR)/commands.o \
		$(BUILD_DIR)/idt.o \
		$(BUILD_DIR)/input.o \
		$(BUILD_DIR)/keyboard.o \
		$(BUILD_DIR)/print.o \
		$(BUILD_DIR)/math.o \
		$(BUILD_DIR)/string.o \
		$(BUILD_DIR)/about.o \
		$(BUILD_DIR)/calc.o \
		$(BUILD_DIR)/cmd.o \
		$(BUILD_DIR)/libsolaros_rust.a
	objcopy -O binary $(BUILD_DIR)/solaros.bin $(BUILD_DIR)/solaros.bin

build_img: $(BUILD_DIR)
	dd if=/dev/zero of=$(BUILD_DIR)/solaros.img bs=512 count=2880 status=none
	dd if=$(BUILD_DIR)/solaros.bin of=$(BUILD_DIR)/solaros.img conv=notrunc status=none
	@echo "Build complete: $(BUILD_DIR)/solaros.img"

run: build_img
	$(QEMU) $(QEMU_FLAGS)

clean:
	rm -rf $(BUILD_DIR)
	cd $(RUST_DIR) && $(CARGO) clean
