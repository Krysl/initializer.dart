import 'package:build/build.dart';
import 'package:initializer_annotation/initializer_annotation.dart';
import 'package:source_gen/source_gen.dart';

// import 'check_dependencies.dart';
// import 'json_enum_generator.dart';
// import 'json_literal_generator.dart';
// import 'json_serializable_generator.dart';
import 'settings.dart';

/// Returns a [Builder] for use within a `package:build_runner`
/// `BuildAction`.
///
/// [formatOutput] is called to format the generated code. If not provided,
/// the default Dart code formatter is used.
Builder partBuilder({
  String Function(String code)? formatOutput,
  Initializer? config,
}) {
  final settings = Settings(config: config);

  return SharedPartBuilder(
    [
      // _UnifiedGenerator([
      //   JsonSerializableGenerator.fromSettings(settings),
      //   const JsonEnumGenerator(),
      // ]),
      // const JsonLiteralGenerator(),
    ],
    'json_serializable',
    formatOutput: formatOutput,
  );
}