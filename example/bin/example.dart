import 'package:example/example.dart' as example;
import 'package:example/init.init.dart';
import 'package:initializer_annotation/initializer_annotation.dart';

void main(List<String> arguments) {
  initializer(
    enabledefault: true,
    enablegroup2: false,
  );
  assert(example.inited == true);
}

@Initializer() // not work(generated file can not import files outside lib/ when it is inside lib/)
test() {}
