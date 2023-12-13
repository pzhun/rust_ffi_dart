import 'package:flutter_ffi/flutter_ffi.dart';
import 'package:test/test.dart';

void main() {
  test('calculate', () {
    expect(calculate(), 42);
  });

  test("ffi_test", () {
    ffi_test();
  });

  test("ffigen_Test", () {
    ffigen_Test();
  });
}
