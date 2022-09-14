// example/lib/example.dart example\lib
import 'example.dart' show calculate, calculate2, result;
// example/lib/src/src_example.dart example\lib
import 'src/src_example.dart' show srcCalculate, srcCalculate2, srcResult;

void defaultInitializer() {
  result;
  srcResult;
  calculate();
  calculate2();
  srcCalculate();
  srcCalculate2();
}
void initializer({
  bool enabledefault = true,
}) {
  if(enabledefault) defaultInitializer();
}
