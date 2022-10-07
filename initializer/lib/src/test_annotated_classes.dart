// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_gen_test/src/annotations.dart';
import 'package:source_gen_test/src/build_log_tracking.dart';
import 'package:source_gen_test/src/expectation_element.dart';
import 'package:source_gen_test/src/matchers.dart';
import 'package:test/test.dart';

import 'aggregate_generator_for_annotation.dart';
import 'aggregate_results.dart';
import 'generate_for_element.dart';

const _defaultConfigurationName = 'default';

/// If [defaultConfiguration] is not provided or `null`, "default" and the keys
/// from [additionalGenerators] (if provided) are used.
///
/// Tests registered by this function assume [initializeBuildLogTracking] has
/// been called.
///
/// If [expectedAnnotatedTests] is provided, it should contain the names of the
/// members in [libraryReader] that are annotated for testing. If the same
/// element is annotated for multiple tests, it should appear in the list
/// the same number of times.
void testAggregateAnnotatedElements<T, R extends AggregateResults>(
  LibraryReader libraryReader,
  AggregateGeneratorForAnnotation<T, R> defaultGenerator, {
  Map<String, AggregateGeneratorForAnnotation<T, R>>? additionalGenerators,
  Iterable<String>? expectedAnnotatedTests,
  Iterable<String>? defaultConfiguration,
}) {
  for (final entry in getAggregateAnnotatedClasses<T, R>(
    libraryReader,
    defaultGenerator,
    additionalGenerators: additionalGenerators,
    expectedAnnotatedTests: expectedAnnotatedTests,
    defaultConfiguration: defaultConfiguration,
  )) {
    entry._registerTest();
  }
}

/// An implementation member only exposed to make it easier to test
/// [testAggregateAnnotatedElements] without registering any tests.
@visibleForTesting
List<AggregateAnnotatedTest<T, R>>
    getAggregateAnnotatedClasses<T, R extends AggregateResults>(
  LibraryReader libraryReader,
  AggregateGeneratorForAnnotation<T, R> defaultGenerator, {
  Map<String, AggregateGeneratorForAnnotation<T, R>>? additionalGenerators,
  Iterable<String>? expectedAnnotatedTests,
  Iterable<String>? defaultConfiguration,
}) {
  final generators = <String, AggregateGeneratorForAnnotation<T, R>>{
    _defaultConfigurationName: defaultGenerator
  };
  if (additionalGenerators != null) {
    for (final invalidKey in const [_defaultConfigurationName, '']) {
      if (additionalGenerators.containsKey(invalidKey)) {
        throw ArgumentError.value(
          additionalGenerators,
          'additionalGenerators',
          'Contained an unsupported key "$invalidKey".',
        );
      }
    }
    if (additionalGenerators.containsKey(null)) {
      throw ArgumentError.value(
        additionalGenerators,
        'additionalGenerators',
        'Contained an unsupported key `null`.',
      );
    }
    generators.addAll(additionalGenerators);
  }

  Set<String> defaultConfigSet;

  if (defaultConfiguration != null) {
    defaultConfigSet = defaultConfiguration.toSet();
    if (defaultConfigSet.isEmpty) {
      throw ArgumentError.value(
        defaultConfiguration,
        'defaultConfiguration',
        'Cannot be empty.',
      );
    }

    final unknownShouldThrowDefaults =
        defaultConfigSet.where((v) => !generators.containsKey(v)).toSet();
    if (unknownShouldThrowDefaults.isNotEmpty) {
      throw ArgumentError.value(
        defaultConfiguration,
        'defaultConfiguration',
        'Contains values not associated with provided generators: '
            '${unknownShouldThrowDefaults.map((v) => '"$v"').join(', ')}.',
      );
    }
  } else {
    defaultConfigSet = generators.keys.toSet();
  }

  final annotatedElements =
      genAnnotatedElements(libraryReader, defaultConfigSet);

  final unusedConfigurations = generators.keys.toSet();
  for (final annotatedElement in annotatedElements) {
    unusedConfigurations
        .removeAll(annotatedElement.expectation.configurations!);
  }
  if (unusedConfigurations.isNotEmpty) {
    if (unusedConfigurations.contains(_defaultConfigurationName)) {
      throw ArgumentError(
        'The `defaultGenerator` is not used by any annotated elements.',
      );
    }

    throw ArgumentError(
      'Some of the specified generators were not used for their corresponding '
      'configurations: '
      '${unusedConfigurations.map((c) => '"$c"').join(', ')}.\n'
      'Remove the entry from `additionalGenerators` or update '
      '`defaultConfiguration`.',
    );
  }

  if (expectedAnnotatedTests != null) {
    final expectedList = expectedAnnotatedTests.toList();

    final missing = <String>[];

    for (final elementName in annotatedElements.map((e) => e.elementName)) {
      if (!expectedList.remove(elementName)) {
        missing.add(elementName);
      }
    }

    if (expectedList.isNotEmpty) {
      throw ArgumentError.value(
        expectedList.map((e) => "'$e'").join(', '),
        'expectedAnnotatedTests',
        'There are unexpected items',
      );
    }
    if (missing.isNotEmpty) {
      throw ArgumentError.value(
        missing.map((e) => "'$e'").join(', '),
        'expectedAnnotatedTests',
        'There are items missing',
      );
    }
  }

  final result = <AggregateAnnotatedTest<T, R>>[];

  // element name -> missing configs
  final mapMissingConfigs = <String, Set<String>>{};

  for (final entry in annotatedElements) {
    for (final configuration in entry.expectation.configurations!) {
      final generator = generators[configuration];

      if (generator == null) {
        mapMissingConfigs
            .putIfAbsent(entry.elementName, () => <String>{})
            .add(configuration);
        continue;
      }

      result.add(
        AggregateAnnotatedTest<T, R>._(
          libraryReader,
          generator,
          configuration,
          entry.elementName,
          entry.expectation,
        ),
      );
    }
  }

  if (mapMissingConfigs.isNotEmpty) {
    final elements = mapMissingConfigs.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final message = elements.map((e) {
      final sortedConfigs =
          (e.value.toList()..sort()).map((v) => '"$v"').join(', ');
      return '`${e.key}`: $sortedConfigs';
    }).join('; ');

    throw ArgumentError(
      'There are elements defined with configurations with no associated '
      'generator provided.\n$message',
    );
  }

  return result;
}

@visibleForTesting
class AggregateAnnotatedTest<T, R extends AggregateResults> {
  final AggregateGeneratorForAnnotation<T, R> generator;
  final String configuration;
  final LibraryReader _libraryReader;
  final TestExpectation expectation;
  final String _elementName;

  String get _testName {
    var value = _elementName;
    if (configuration != _defaultConfigurationName) {
      value += ' with configuration "$configuration"';
    }
    return value;
  }

  AggregateAnnotatedTest._(
    this._libraryReader,
    this.generator,
    this.configuration,
    this._elementName,
    this.expectation,
  );

  void _registerTest() {
    if (expectation is ShouldGenerate) {
      test(_testName, _shouldGenerateTest);
      return;
    } else if (expectation is ShouldThrow) {
      test(_testName, _shouldThrowTest);
      return;
    }
    throw StateError('Should never get here.');
  }

  Future<String> _generate() =>
      generateForElement<T, R>(generator, _libraryReader, _elementName);

  Future<void> _shouldGenerateTest() async {
    final output = await _generate();
    final exp = expectation as ShouldGenerate;

    try {
      expect(
        output,
        exp.contains
            ? contains(exp.expectedOutput)
            : equals(exp.expectedOutput),
      );
    } on TestFailure {
      printOnFailure("ACTUAL CONTENT:\nr'''\n$output'''");
      rethrow;
    }

    expect(
      buildLogItems,
      exp.expectedLogItems,
      reason: 'The expected log items do not match.',
    );
    clearBuildLog();
  }

  Future<void> _shouldThrowTest() async {
    final exp = expectation as ShouldThrow;

    Matcher? elementMatcher;

    if (exp.element == null || exp.element is String) {
      String expectedElementName;
      if (exp.element == null) {
        expectedElementName = _elementName;
      } else {
        assert(exp.element is String);
        expectedElementName = exp.element as String;
      }
      elementMatcher = const TypeMatcher<Element>()
          .having((e) => e.name, 'name', expectedElementName);
    } else if (exp.element == true) {
      elementMatcher = isNotNull;
    } else {
      assert(exp.element == false);
    }

    await expectLater(
      _generate,
      throwsInvalidGenerationSourceError(
        exp.errorMessage,
        todoMatcher: exp.todo,
        elementMatcher: elementMatcher,
      ),
    );

    expect(
      buildLogItems,
      exp.expectedLogItems,
      reason: 'The expected log items do not match.',
    );
    clearBuildLog();
  }
}
