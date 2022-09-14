import 'package:initializer/initializer.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen_test/source_gen_test.dart';

void main() async {
  initializeBuildLogTracking();
  final initializerTestReader = await initializeLibraryReaderForDirectory(
    p.join('test', 'src'),
    '_initializer_test_input.dart',
  );
  testAnnotatedElements(
    initializerTestReader,
    InitializerGenerator(),
    expectedAnnotatedTests: _expectedAnnotatedTests,
  );
}

const _expectedAnnotatedTests = <String>{
  'UnsupportedEnum',
  'init',
  'initSync',
};
