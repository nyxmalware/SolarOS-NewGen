#![no_std]
#![no_main]

use core::panic::PanicInfo;

#[no_mangle]
pub extern "C" fn rust_init() {
    // инициализация rust рантайма
}

#[no_mangle]
pub extern "C" fn rust_strlen(s: *const u8) -> usize {
    let mut len = 0;
    unsafe {
        while *s.add(len) != 0 {
            len += 1;
        }
    }
    len
}

#[no_mangle]
pub extern "C" fn rust_strcmp(s1: *const u8, s2: *const u8) -> i32 {
    let mut i = 0;
    unsafe {
        while *s1.add(i) != 0 && *s2.add(i) != 0 {
            if *s1.add(i) != *s2.add(i) {
                return (*s1.add(i) as i32) - (*s2.add(i) as i32);
            }
            i += 1;
        }
        (*s1.add(i) as i32) - (*s2.add(i) as i32)
    }
}

#[no_mangle]
pub extern "C" fn rust_calc(a: i32, b: i32, op: u8) -> i32 {
    match op {
        b'+' => a + b,
        b'-' => a - b,
        b'*' => a * b,
        b'/' => if b != 0 { a / b } else { 0 },
        _ => 0,
    }
}

#[no_mangle]
pub extern "C" fn rust_sqrt(x: i32) -> i32 {
    if x <= 0 { return 0; }
    let mut guess = x as f64;
    for _ in 0..10 {
        guess = (guess + (x as f64) / guess) * 0.5;
    }
    guess as i32
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
