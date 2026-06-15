<h1 align="center">
  <img src="https://img.shields.io/badge/SolarOS-NewGen-3AAFA9?style=for-the-badge&labelColor=1F2937" alt="SolarOS NewGen">
  <br>
   64-bit Operating System with GUI
</h1>

<p align="center">
  <img src="https://img.shields.io/badge/arch-x86__64-blue?style=flat-square&labelColor=1F2937&color=3AAFA9" alt="arch">
  <img src="https://img.shields.io/badge/lang-C,ASM-00599C?style=flat-square&labelColor=1F2937" alt="lang">
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square&labelColor=1F2937&color=57AB5B" alt="license">
  <img src="https://img.shields.io/badge/status--alpha-yellow?style=flat-square&labelColor=1F2937&color=D4A72C" alt="status">
</p>

<p align="center">
  Modern rewrite of SolarOS from scratch.<br>
  64-bit Long Mode · VBE GUI · PS/2 Mouse/Keyboard · PIC/PIT · FAT32
</p>

---

## 📊 SolarOS NewGen vs Legacy v2.0

| Характеристика | SolarOS v2.0 (Legacy) | SolarOS NewGen 0.0.1 |
|:---|:---:|:---:|
| **Архитектура** | 16-bit Real Mode | 64-bit Long Mode |
| **Максимум памяти** | 1 MB | 4 GB+ |
| **Защита памяти** | ❌ Сегментация | ✅ Paging |
| **Многозадачность** | ❌ Только переключение | ✅ Кооперативная |
| **Графический режим** | 640x480x16 (VBE) | 640x480x32 (LFB) |
| **GUI (окна/таск-бар)** | ✅ | ✅ |
| **Ввод клавиатуры в GUI** | ❌ | ✅ |
| **Калькулятор** | ❌ Не работал | ✅ Полностью рабочий |
| **Мышь** | ✅ PS/2 | ✅ PS/2 |
| **Таймер (PIT)** | ❌ Заглушка | ✅ 100 Hz |
| **Прерывания** | BIOS (int 0x10,0x16,0x33) | IDT + PIC |
| **Файловая система** | FAT12 | FAT32 (в разработке) |
| **Язык разработки** | ASM + Rust (2%) | C + ASM |
---

## ✨ Features

### 🖥️ GUI Desktop
- 640x480 32-bit VBE framebuffer
- Movable windows with title bars
- Taskbar with Start menu and clock
- Desktop icons (Calculator, About, Exit)
- Full keyboard input for windows

### ⌨️ Hardware Support
- PS/2 Keyboard with Shift/CapsLock
- PS/2 Mouse with cursor tracking
- PIT Timer (100 Hz) for system ticks
- PIC remapped (IRQ0-15)

### 🧠 Core System
- 64-bit long mode
- GDT (Null, Code, Data segments)
- IDT with 256 interrupt vectors
- Simple bump allocator (4MB heap)
- Serial debug (COM1)

### 📝 Built-in Apps
| App | Description |
|:---|:---|
| **Calculator** | Basic arithmetic (+ - * /), error handling, keyboard input |
| **About** | System information |
| **Shell (CLI)** | Commands: help, clear, reboot, shutdown, mem, gui |

---

## 🔧 Build & Run

### Prerequisites
```bash
# Ubuntu/Debian
sudo apt install nasm gcc qemu-system-x86 make

# Arch
sudo pacman -S nasm gcc qemu-desktop make
