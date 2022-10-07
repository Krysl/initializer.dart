// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'aggregate_generator.dart';
import 'aggregate_results.dart';
import 'output_helpers.dart';

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
      await for (final value in normalizeGeneratorOutput<R>(generatedValue)) {
        if (values.containsKey(value.key)) {
          values[value.key]!.merge(value.value);
        } else {
          values[value.key] = value.value;
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
}
