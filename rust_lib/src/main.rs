fn main() {
    println!("Hello World!");

    let result = num2num(10);
    println!("{}", result);
}

#[no_mangle]
pub extern "C" fn num2num(num: u32) -> u32 {
    let result = num + 1;
    return result;
}
