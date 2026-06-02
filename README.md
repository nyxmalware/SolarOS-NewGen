SOLAROS v1.5 - 16-bit GUI Operating System

SolarOS is a 16-bit real mode OS with graphical desktop environment. Built with NASM assembly. Runs on FAT12.

FEATURES:
- Text mode CLI with commands (help, clear, reboot, shutdown, mem, desk)
- Graphical desktop 640x480 with icons
- Window manager with movable windows
- Start menu (Shutdown / Exit to CMD)
- Mouse & keyboard support
- Built-in apps: Calculator, About
- FAT12 filesystem driver

BUILD:
nasm -f bin boot.asm -o boot.bin
nasm -f bin initrix.asm -o initrix.bin
nasm -f bin kernel.asm -o kernel.bin
dd if=/dev/zero of=solaros.img bs=512 count=2880
dd if=boot.bin of=solaros.img conv=notrunc
dd if=initrix.bin of=solaros.img seek=2 conv=notrunc
dd if=kernel.bin of=solaros.img seek=4 conv=notrunc

RUN:
qemu-system-x86_64 -fda solaros.img

COMMANDS:
help, clear, reboot, shutdown, mem, ver, desk, gui

CREDITS:
Based on RealixOS by NightFox-YT. Extended with GUI and desktop.

LICENSE: MIT
(c) 2026 SolarOS Team
