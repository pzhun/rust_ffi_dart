### 调用流程

1、**cargo build**，在rust项目，target目录下生成 .so(linux) 或 .dylib(mac) 文件。

2、拷贝该文件至dart项目下，安装依赖，dart pub add ffi。

3、**读取动态链接库**，final ffi.DynamicLibrary dylib = ffi.DynamicLibrary.open('./rust_so/libcasher.so'); 。

4、**实参转化为动态链接库中函数可以用的数据**，final ffi.Pointer<Utf8> **charPointer** = file_name.toNativeUtf8();

5、**获取函数指针**，**fun**=dylib.lookupFunction<函数在rust中的签名（传入），函数在dart中的签名（调用）>（查找的函数名称，isLeaf: true）

rust中：例如，pub extern "C" fn **play_once**(ptr: *const c_char) -> **u32**  ，这是一个函数名为play_once，传参名为ptr，类型为\*const c_char，表示指向null结尾的c字符串。u32为返回值类型。传参与返回值一般都是指针。

dart中：函数的签名与rust中保持一致。

6、**调用函数**。 fun(chartPoint)， 

#### 注意：

函数在rust中的签名，都得是rust可以接受的，即ffi库中的

函数在dart中的签名，需要是对应的在rust中数据结构，如果没有，则用ffi库中的，比如指针。

传参为数组或字符串时，不可以直接传入，需要进行转化处理。

返回值为指针时，也需要进一步处理。

分配的内存记得回收，一般出现在对传入参数的处理中。

### 自动生成工具

通过 **ffigen**库 自动生成 dart语句，可以代替，调用流程中比较麻烦的**步骤5**，但需要正确的C头文件

1、**安装依赖**：dart pub add ffigen

2、**安装LLVM.** Linux: sudo apt-get install libclang-dev || MacOS: xcode-select --install; brew install llvm;

3、**编写配置文件**，在pubspec.yaml下

```yaml
ffigen:
  output: 'lib/ffigen.dart'
  headers:
    entry-points:
      - 'rust_lib/example.h'
```

4、**生成dart代码**: dart run ffigen

