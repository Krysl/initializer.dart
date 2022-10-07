import 'package:initializer_annotation/initializer_annotation.dart';

@Initializer()
final result = calculate();

@Initializer()
int calculate() {
  return 6 * 7;
}

@Initializer(group: 'group2')
int calculate2() {
  return 6 * 7;
}

@Initializer()
class InitA {
  @Initializer()
  static final initVar = init();

  static late final int _init;
  @Initializer()
  static int init() {
    _init = 1;
    return _init;
  }
}
