import 'package:example/example.dart';
import 'package:example/init.init.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() => initializer(
        enablegroup1: false,
        enablegroup2: false,
      ));
  test('inited', () {
    expect(inited, true);
  });
}
