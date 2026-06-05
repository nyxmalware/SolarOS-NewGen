# SolarOS Makefile - полный фикс
NASM = nasm
QEMU = qemu-system-x86_64
BUILD_DIR = build
IMG = solaros.img

# флаги для 16-битного реального режима (НЕ -f elf32!)
ASM_FLAGS = -f bin

.PHONY: all clean run

all: $(BUILD_DIR) $(IMG)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# сборка загрузчика (16-bit real mode)
$(BUILD_DIR)/boot.bin: boot.asm
	$(NASM) $(ASM_FLAGS) boot.asm -o $(BUILD_DIR)/boot.bin

# сборка initrix
$(BUILD_DIR)/initrix.bin: initrix.asm
	$(NASM) $(ASM_FLAGS) initrix.asm -o $(BUILD_DIR)/initrix.bin

# сборка ядра (тоже 16-bit)
$(BUILD_DIR)/kernel.bin: kernel.asm
	$(NASM) $(ASM_FLAGS) kernel.asm -o $(BUILD_DIR)/kernel.bin

# создание образа дискеты
$(IMG): $(BUILD_DIR)/boot.bin $(BUILD_DIR)/initrix.bin $(BUILD_DIR)/kernel.bin
	dd if=/dev/zero of=$(IMG) bs=512 count=2880 status=none
	dd if=$(BUILD_DIR)/boot.bin of=$(IMG) conv=notrunc status=none
	dd if=$(BUILD_DIR)/initrix.bin of=$(IMG) seek=2 conv=notrunc status=none
	dd if=$(BUILD_DIR)/kernel.bin of=$(IMG) seek=4 conv=notrunc status=none
	@echo "=== SolarOS build complete ==="
	@echo "Image: $(IMG)"

# запуск в эмуляторе
run: $(IMG)
	$(QEMU) -fda $(IMG) -m 32

# очистка
clean:
	rm -rf $(BUILD_DIR) $(IMG)
	@echo "Clean complete"
