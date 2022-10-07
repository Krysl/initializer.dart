import 'package:initializer_annotation/initializer_annotation.dart';

@Initializer()
final srcResult = srcCalculate();

@Initializer()
int srcCalculate() {
  return 6 * 7;
}

@Initializer(group: 'group2')
int srcCalculate2() {
  return 6 * 7;
}
