#![no_std]
#![no_main]

mod apps;
mod fs;
mod mem;
mod utils;

use core::panic::PanicInfo;

#[no_mangle]
pub extern "C" fn rust_init() {
    mem::alloc::init_heap();
}

#[no_mangle]
pub extern "C" fn rust_calc(expr: *const u8) -> i32 {
    apps::rcalc::calculate(expr)
}

#[no_mangle]
pub extern "C" fn rust_edit(filename: *const u8) {
    apps::reditor::open_editor(filename);
}

#[no_mangle]
pub extern "C" fn rust_filemgr() {
    fs::filemgr::show_browser();
}

#[no_mangle]
pub extern "C" fn rust_sqrt(x: i32) -> i32 {
    utils::math::sqrt(x as f64) as i32
}

#[no_mangle]
pub extern "C" fn rust_strlen(s: *const u8) -> usize {
    utils::string::strlen(s)
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
