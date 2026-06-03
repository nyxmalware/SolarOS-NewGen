NASM = nasm
RUSTC = cargo
LD = ld
QEMU = qemu-system-x86_64
IMG = solaros.img

ASM_FILES = boot.asm initrix.asm kernel.asm
ASM_OBJS = boot.o initrix.o kernel.o

all: build_asm build_rust link build_img

build_asm:
	$(NASM) -f elf32 boot.asm -o boot.o
	$(NASM) -f elf32 initrix.asm -o initrix.o
	$(NASM) -f elf32 kernel.asm -o kernel.o

build_rust:
	cd rust && $(RUSTC) build --release

link:
	$(LD) -m elf_i386 -T link.ld -o solaros.bin $(ASM_OBJS) rust/target/release/libsolaros_rust.a

build_img:
	objcopy -O binary solaros.bin $(IMG)

clean:
	rm -f *.o *.bin $(IMG)
	cd rust && $(RUSTC) clean

run:
	$(QEMU) -fda $(IMG)

.PHONY: all build_asm build_rust link build_img clean run
