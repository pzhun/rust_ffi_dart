import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

import 'ffigen.dart';

/// 函数签名定义，ffi中的数据结构，都为在C语言中的对应
/// 指向字符串的指针，指针在dart中没有完全等价的数据结构，所以，dart与rust中函数签名都是ffi中的指针。
typedef TypeString = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>);

/// 返回值为浮点型的函数，Float对应double
typedef Type1InRust = ffi.Float Function();
typedef Type1InDart = double Function();

/// 返回值为无符号整数，由于dart中没有原生的uint类型，这里用int代替。传递负数时会报错
typedef Type2Rust = ffi.Uint32 Function(ffi.Uint32, ffi.Uint32);
typedef Type2InDart = int Function(int, int);

/// 返回值与传参都为数组，C中没有定长数组，所以在传递数组指针时，需要带数组长度。
/// 传递时，需要先转化为C中可以处理的指针，然后把数据拷贝进指向的区域（需要释放内存），返回值也需要做类似处理。
typedef Type3Rust = ffi.Pointer<ffi.Uint8> Function(
    ffi.Pointer<ffi.Uint8>, ffi.Int32);
typedef Type3InDart = ffi.Pointer<ffi.Uint8> Function(
    ffi.Pointer<ffi.Uint8>, int);

/// 传递结构体，结构体本质也是指针，首先需要定义出对应的结构体类型
typedef CreatePersonRust = ffi.Pointer<Person> Function(
    ffi.Pointer<Utf8>, ffi.Int32, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>);
typedef CreatePersonDart = ffi.Pointer<Person> Function(
    ffi.Pointer<Utf8>, int, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>);

final class Address extends ffi.Struct {
  external ffi.Pointer<Utf8> city;

  external ffi.Pointer<Utf8> street;
}

final class Person extends ffi.Struct {
  external ffi.Pointer<Utf8> name;

  @ffi.Uint8()
  external int age;

  external Address address;
}

final ffi.DynamicLibrary dyLib =
    ffi.DynamicLibrary.open('./dart_ffi/rust_lib/libcasher.so');
void ffi_test() {
  const String file_name = 'test_rust_ffi';

  // Convert a Dart [String] to a Utf8-encoded null-terminated C string.
  final ffi.Pointer<Utf8> charPointer = file_name.toNativeUtf8();

  dynamic result;

  /// Type中申明的返回值为指针，.address转为实际值（大概这个意思）。
  var str2num = dyLib.lookupFunction<ffi.Pointer<Utf8> Function(),
      ffi.Pointer<Utf8> Function()>('return_num', isLeaf: true);
  result = str2num().address;
  printLn(result);

  /// 这里返回值为float，可以直接打印
  var str2float = dyLib.lookupFunction<Type1InRust, Type1InDart>('return_float',
      isLeaf: true);
  result = str2float();
  printLn(result);

  /// 简单的加法
  var addNumber =
      dyLib.lookupFunction<Type2Rust, Type2InDart>('numbers_add', isLeaf: true);
  result = addNumber(1, 10);
  printLn(result);
  // result = addNumber(-1, 10);// 报错
  // printLn(result);

  /// 返回值为字符串时，为字符串指针，转为dart字符串。
  var copyChar =
      dyLib.lookupFunction<TypeString, TypeString>('str2str', isLeaf: true);
  result = copyChar(charPointer).toDartString();
  printLn(result);

  /// 参数与返回值都为数组
  // 创建一个指向数组的内存块
  final u8List = [0, 1, 1, 3, 4, 5, 1, 3, 2];
  final ptr = calloc<ffi.Uint8>(u8List.length);
  // 将数组的值复制到内存块中
  final arrayPtr = ptr.asTypedList(u8List.length);
  arrayPtr.setAll(0, u8List);
  var List2List =
      dyLib.lookupFunction<Type3Rust, Type3InDart>('list2List', isLeaf: true);
  result = List2List(ptr, u8List.length).asTypedList(u8List.length);
  printLn(result);

  /// 释放内存
  calloc.free(ptr);
  calloc.free(charPointer);

  /// 传递结构体

  final createPerson = dyLib.lookupFunction<CreatePersonRust, CreatePersonDart>(
      'create_person',
      isLeaf: true);

  final authorPtr = createPerson(
    'WX'.toNativeUtf8(),
    27,
    'Shen Zhen'.toNativeUtf8(),
    'Yue Hai'.toNativeUtf8(),
  );

  final author = authorPtr.ref;
  final name = author.name.toDartString();
  final age = author.age;
  final city = author.address.city.toDartString();
  final street = author.address.street.toDartString();
  print("My name is $name, I'm $age years old, I live in $city $street street");
}

void ffigen_Test() {
  final ffigen = NativeLibrary(dyLib);
  print(ffigen.numbers_add(10, 20));
}

void printLn(result) {
  print(result);
  print("==============");
}

int calculate() {
  return 6 * 7;
}
