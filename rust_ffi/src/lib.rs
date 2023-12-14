use std::ffi::CStr;
use std::ffi::CString;
use std::os::raw::c_char;

#[no_mangle]
pub extern "C" fn return_num() -> u32 {
    let return_num = 10;
    return_num
}

#[no_mangle]
pub extern "C" fn return_float() -> f32 {
    let s: f32 = 11.0;
    s
}

#[no_mangle]
pub extern "C" fn numbers_add(a: u32, b: u32) -> u32 {
    let result = a + b;
    result
}

#[no_mangle]
pub extern "C" fn str2str(ptr: *const c_char) -> *const c_char {
    let cstr = unsafe { CStr::from_ptr(ptr) };
    let a: &str = cstr.to_str().unwrap();
    let mut result = String::from(a);
    result.push_str(a);
    let c_str_song = CString::new(result).unwrap();
    c_str_song.into_raw()
}

#[no_mangle]
pub extern "C" fn list2List(array: *const u8, length: usize) -> *const u8 {
    for i in 0..length {
        let item = unsafe { *array.offset(i as isize) };
        println!("array[{}] = {}", i, item);
    }
    array
}

#[repr(C)]
pub struct Address {
    city: *const c_char,
    street: *const c_char,
}

#[repr(C)]
pub struct Person {
    name: *const c_char,
    age: u8,
    address: Address,
}

#[no_mangle]
pub extern "C" fn create_person(
    name: *const c_char,
    age: u8,
    city: *const c_char,
    street: *const c_char,
) -> *mut Person {
    Box::into_raw(Box::new(Person {
        name,
        age,
        address: Address { city, street },
    }))
}
