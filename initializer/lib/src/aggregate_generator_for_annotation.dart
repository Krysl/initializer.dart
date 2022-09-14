// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:async/async.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'aggregate_generator.dart';
import 'aggregate_results.dart';

abstract class AggregateGeneratorForAnnotation<T, R extends AggregateResults>
    extends AggregateGenerator<R> {
  const AggregateGeneratorForAnnotation();

  TypeChecker get typeChecker => TypeChecker.fromRuntime(T);

  @override
  FutureOr<Map<String, R>> generate(
      LibraryReader library, BuildStep buildStep) async {
    final values = <String, R>{};

    for (final annotatedElement in library.annotatedWith(typeChecker)) {
      final generatedValue = generateForAnnotatedElement(
        annotatedElement.element,
        annotatedElement.annotation,
        buildStep,
      );
      await for (final value in normalizeGeneratorOutput(generatedValue)) {
        if (values.containsKey(value.key)) {
          values[value.key]!.merge(value.value);
        } else {
          values.addEntries([value]);
        }
      }
    }

    return values;
  }

  MapEntry<String, R> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  );

  /// Converts [Future], [Iterable], and [Stream] implementations
  /// containing [MapEntry<String, R>] to a single [Stream] while ensuring all thrown
  /// exceptions are forwarded through the return value.
  Stream<MapEntry<String, R>> normalizeGeneratorOutput(Object? value) {
    if (value == null) {
      return const Stream.empty();
    } else if (value is Future) {
      return StreamCompleter.fromFuture(value.then(normalizeGeneratorOutput));
    } else if (value is MapEntry<String, R>) {
      value = [value];
    }

    if (value is Iterable) {
      value = Stream.fromIterable(value);
    }

    if (value is Stream) {
      return value.where((e) => e != null).map((e) {
        if (e is MapEntry<String, R>) {
          return e;
        }

        throw argError(e as Object);
      });
    }
    throw argError(value);
  }

  ArgumentError argError(Object value) => ArgumentError(
        'Must be a MapEntry<String, $R> or be an Iterable/Stream containing MapEntry<String, $R> values. '
        'Found `${Error.safeToString(value)}` (${value.runtimeType}).',
      );
}
