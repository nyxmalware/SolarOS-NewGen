mod drivers;
mod gui;
mod apps;
mod shell;
mod memory;
mod boot;

#[no_mangle]
pub extern "C" fn _start() -> ! {
    // код ядра
}
