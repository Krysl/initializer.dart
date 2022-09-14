import 'package:example/example.dart' as example;
import 'package:initializer_annotation/initializer_annotation.dart';

void main(List<String> arguments) {
  print('Hello world: ${example.calculate()}!');
}

@Initializer() // not work(generated file can not import files outside lib/ when it is inside lib/)
test() {}
