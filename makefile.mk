NASM = nasm
RUSTC = cargo
LD = ld
QEMU = qemu-system-x86_64
IMG = solaros.img

ASM_OBJS = initrix.o kernel.o

all: build_asm build_rust link build_img

build_asm:
	$(NASM) -f bin boot.asm -o boot.bin
	$(NASM) -f elf32 initrix.asm -o initrix.o
	$(NASM) -f elf32 kernel.asm -o kernel.o

build_rust:
	cd rust && $(RUSTC) build --release

link:
	$(LD) -m elf_i386 -T link.ld -o solaros.bin initrix.o kernel.o rust/target/release/libsolaros_rust.a

build_img:
	cat boot.bin solaros.bin > $(IMG)

clean:
	rm -f boot.bin *.o *.bin *.img
	cd rust && $(RUSTC) clean

run:
	$(QEMU) -fda $(IMG)

.PHONY: all build_asm build_rust link build_img clean run
