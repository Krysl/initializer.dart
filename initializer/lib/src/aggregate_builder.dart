import 'dart:async';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

import 'aggregate_generator.dart';
import 'aggregate_results.dart';

class AggregateBuilder implements Builder {
  List<AggregateGenerator> generators;
  String outputPath;

  final bool _debug;
  void debug(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _debug ? log.info(message, error, stackTrace) : null;

  AggregateBuilder({
    required this.outputPath,
    required this.generators,
    bool debug = false,
  }) : _debug = debug {
    if (!outputPath.endsWith('.init.dart')) {
      throw ArgumentError(
          'outputPath should endswith ".init.dart", but you set it to $outputPath');
    }
    if (p.isAbsolute(outputPath)) {
      throw ArgumentError(
          'outputPath must be relative path, but you set it to a abslute path: $outputPath');
    }
  }
  static final _allFilesInLib = Glob('lib/**.dart');

  AssetId _allFileOutput(BuildStep buildStep) => AssetId(
        buildStep.inputId.package,
        outputPath,
      );

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    final group = AggregateResultsGroup(
      rootPackage: inputId.package,
      outputPath: outputPath,
    );
    await for (final input in buildStep.findAssets(_allFilesInLib)) {
      try {
        final library = await buildStep.resolver.libraryFor(input);
        final libraryReader = LibraryReader(library);

        var hasGenerated = false;
        for (final generator in generators) {
          final result = await generator.generate(
            libraryReader,
            buildStep,
          );
          if (result != null && result.isNotEmpty) hasGenerated = true;
          group.addAll(result);
        }
        if (hasGenerated) {
          debug(
              '====== AggregateBuilder build for $input ${input.path} ======');
        }
      } on NonLibraryAssetException catch (_) {}
    }

    final output = _allFileOutput(buildStep);
    return buildStep.writeAsString(
      output,
      group.toString(),
    );
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        // r'$package$': [outputPath],
        r'lib/$lib$': [outputPath],
      };
}
