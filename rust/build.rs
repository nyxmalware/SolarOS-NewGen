fn main() {
    println!("cargo:rerun-if-changed=src/");
    println!("cargo:rustc-flags=-C link-arg=-nostartfiles");
}
