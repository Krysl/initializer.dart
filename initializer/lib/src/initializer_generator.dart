// ignore_for_file: implementation_imports, unnecessary_import
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:initializer_annotation/initializer_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'aggregate_generator_for_annotation.dart';
import 'aggregate_results.dart';
import 'settings.dart';

class InitializerAggregateResults extends AggregateResults {
  final List<TopLevelVariableElementImpl> _topLevelVariable = [];
  final List<FunctionElementImpl> _initFunction = [];
  final List<FieldElementImpl> _initField = [];
  final List<MethodElementImpl> _initMethod = [];

  final String groupName;
  @override
  final String path;
  InitializerAggregateResults({
    required this.groupName,
    required this.path,
  });

  @override
  String toString() {
    final strbuf = StringBuffer() //
      ..writeln('void ${groupName}Initializer() {');
    if (_topLevelVariable.isNotEmpty) {
      for (final variable in _topLevelVariable) {
        strbuf.writeln('  ${variable.identifier};');
      }
    }
    if (_initFunction.isNotEmpty) {
      for (final fn in _initFunction) {
        strbuf.writeln('  ${fn.identifier}();');
      }
    }
    if (_initField.isNotEmpty) {
      for (final f in _initField) {
        final klass = f.enclosingElement3 as ClassElementImpl;
        strbuf.writeln('  ${klass.identifier}.${f.identifier};');
      }
    }
    if (_initMethod.isNotEmpty) {
      for (final m in _initMethod) {
        final klass = m.enclosingElement3 as ClassElementImpl;
        strbuf.writeln('  ${klass.identifier}.${m.identifier}();');
      }
    }
    strbuf.write('}');
    return strbuf.toString();
  }

  @override
  void merge(InitializerAggregateResults other) {
    _topLevelVariable.addAll(other._topLevelVariable);
    _initFunction.addAll(other._initFunction);
    super.merge(other);
  }

  void addTopLevelVariable(TopLevelVariableElementImpl e) {
    _topLevelVariable.add(e);
    addSourceMap(e.source.uri, e.identifier);
  }

  void addFunction(FunctionElementImpl e) {
    _initFunction.add(e);
    addSourceMap(e.source.uri, e.identifier);
  }

  void addField(FieldElementImpl e) {
    _initField.add(e);
    final klass = e.enclosingElement3 as ClassElementImpl;
    addSourceMap(e.librarySource.uri, klass.identifier);
  }

  void addMethod(MethodElementImpl e) {
    _initMethod.add(e);
    final klass = e.enclosingElement3 as ClassElementImpl;
    addSourceMap(e.librarySource.uri, klass.identifier);
  }
}

class InitializerGenerator extends AggregateGeneratorForAnnotation<Initializer,
    InitializerAggregateResults> {
  final Settings _settings;

  Initializer get config => _settings.config.toInitializer();

  const InitializerGenerator.fromSettings(this._settings);

  factory InitializerGenerator({
    Initializer? config,
  }) =>
      InitializerGenerator.fromSettings(
        Settings(config: config),
      );

  @override
  MapEntry<String, InitializerAggregateResults> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final group = annotation.read('group');
    final groupString = group.isNull ? 'default' : group.stringValue;
    final result = InitializerAggregateResults(
      groupName: groupString,
      path: element.source!.fullName,
    );
    if (element is TopLevelVariableElementImpl) {
      result.addTopLevelVariable(element);
    } else if (element is FunctionElementImpl) {
      result.addFunction(element);
    } else if (element is ClassElementImpl) {
      final klass = element;
      final annotatedFields =
          klass.fields.where((element) => typeChecker.hasAnnotationOf(element));
      for (final field in annotatedFields) {
        if (field is FieldElementImpl) {
          if (field.isStatic) {
            result.addField(field);
          } else {
            throw InvalidGenerationSourceError(
              '`@Initializer` can only be used on STATIC field.',
              element: element,
            );
          }
        }
      }
      final annotatedMethods = klass.methods
          .where((element) => typeChecker.hasAnnotationOf(element));
      for (final method in annotatedMethods) {
        if (method is MethodElementImpl) {
          if (method.isStatic) {
            result.addMethod(method);
          } else {
            throw InvalidGenerationSourceError(
              '`@Initializer` can only be used on STATIC method.',
              element: element,
            );
          }
        }
      }
    } else {
      const supported = [
        'top-level variable',
        'function without required args',
        'static member of class'
      ];
      throw InvalidGenerationSourceError(
        '`@Initializer` can only be used on $supported.',
        element: element,
      );
    }

    return MapEntry<String, InitializerAggregateResults>(groupString, result);
  }
}
