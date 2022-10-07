import 'dart:async';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'aggregate_results.dart';

abstract class AggregateGenerator<R extends AggregateResults> {
  const AggregateGenerator();

  /// Generates Dart code for an input Dart library.
  ///
  /// May create additional outputs through the `buildStep`, but the 'primary'
  /// output is Dart code returned through the Future. If there is nothing to
  /// generate for this library may return null, or a Future that resolves to
  /// null or the empty string.
  FutureOr<Map<String, R>?> generate(
          LibraryReader library, BuildStep buildStep) =>
      null;

  @override
  String toString() => runtimeType.toString();
}
