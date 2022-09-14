import 'dart:convert';

import 'package:build_test/build_test.dart';
import 'package:initializer/initializer.dart';
import 'package:test/test.dart';

const importinitializer =
    "import 'package:initializer_annotation/initializer_annotation.dart';";
const utf8Decoder = Utf8Decoder();
void main() {
  test('test AggregateBuilder', () async {
    final assets = {
      'a|lib/a.globPlaceholder': '',
      'a|lib/a.dart': '''
$importinitializer
@Initializer()
bool initSync() => true;
''',
      'a|lib/b.dart': '',
      'a|lib/c.dart': '',
      'a|lib/d.dart': '',
    };
    final writer = InMemoryAssetWriter();
    final outputs = <String, Object>{
      'a|lib/initializer.dart': '''
initializer() {
  initSync();
}''',
    };

    await testBuilder(
      AggregateBuilder(
        generators: [InitializerGenerator()],
      ),
      assets,
      rootPackage: 'a',
      reader: await PackageAssetReader.currentIsolate(),
      writer: writer,
      outputs: outputs,
    );
    // print(writer.toString());
    // for (final kv in writer.assets.entries) {
    //   print(kv.key);
    //   final val = kv.value;
    //   final str = utf8Decoder.convert(val);
    //   print(str);
    // }
  });
}
