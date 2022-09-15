import 'package:initializer_annotation/initializer_annotation.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldThrow(
    '`@Initializer` can only be used on [top-level variable, function without required args].')
@Initializer() // ignore: invalid_annotation_target
enum UnsupportedEnum { not, valid }

@ShouldGenerate('''
void defaultInitializer() {
  init;
}
''')
@Initializer()
final bool init = initSync();

bool inited = false;

@ShouldGenerate('''
void defaultInitializer() {
  initSync();
}
''')
@Initializer()
bool initSync() {
  // ignore: join_return_with_assignment
  inited = true;
  return inited;
}
