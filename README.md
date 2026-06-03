# SolarOS v2.0 - Hybrid 16-bit OS

SolarOS is a 16-bit real mode operating system with GUI desktop, now hybridized with Rust.

## Features
- Text mode CLI with commands
- Graphical desktop 640x480 with icons
- Window manager with movable windows  
- Start menu (Shutdown / Exit to CMD)
- Mouse & keyboard support
- Built-in apps (Calculator, About)
- FAT12 filesystem
- **NEW:** Rust backend for calculations and string handling

## Build
```bash
make build_asm
make build_rust
make link
make build_img

qemu-system-x86_64 -fda solaros.img

Commands
help, clear, reboot, shutdown, mem, ver, desk, gui

Tech Stack
Assembly (x86) - Core kernel, drivers, GUI

Rust - Calculations, string functions, memory management

Credits
Based on RealixOS by NightFox-YT
Extended with GUI and hybrid Rust/ASM architecture

License
MIT (c) 2026 SolarOS Team
