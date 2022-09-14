import 'package:initializer_annotation/initializer_annotation.dart';

@Initializer()
final result = calculate();

@Initializer()
int calculate() {
  return 6 * 7;
}

@Initializer()
int calculate2() {
  return 6 * 7;
}
