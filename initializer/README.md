<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

This library is just a simple library for integrating initialization code.

Annotate code that needs to be initialized with `@Initializer()` to generate the aggregate function `initializer()`.

Call `initializer()` at the beginning of your program (such as the beginning of `main` function), then the relevant code will be initialized;

## Features

supported types:
- global variable
- global function without required parameters
- static fields of a class 
- static methods of a class without required parameters

## Getting started

1. Add the following to your project's pubspec.yaml and run pub get.
  ```
  dependencies:
    initializer_annotation: ^0.1.0
  dev_dependencies:
    initializer: ^0.1.0
  ```
2. Import initializer_annotation.dart from a file in your project.
  ```dart
  import 'package:initializer_annotation/initializer_annotation.dart';
  ```
3. Annotate your code with classes defined in [package:initializer_annotation](https://pub.dev/packages/initializer_annotation).
- See [example/lib/example.dart](https://github.com/Krysl/initializer.dart/blob/main/example/lib/example.dart) for an example of a file using these annotations.

- See [example/lib/init.init.dart](https://github.com/Krysl/initializer.dart/blob/main/example/lib/init.init.dart) for the generated file.
4. Run `dart run build_runner build` to generate files into your source directory.  
  *NOTE: If you're using Flutter, replace pub run with flutter pub run.*

## Usage

- you can config the `output file path`/`group order` in build.yaml
  ```yaml
  targets:
    $default:
      builders:
        initializer:
          options:
            output_path: lib/init.init.dart
            order:
              - default
              - group1
              - group2
  ```
- use global variable/function(without required parameters)
  ```dart
  @Initializer()
  final initVar = init();

  bool _inited;
  @Initializer()
  bool init() => _inited = true;

  late final bool _inited2;
  @Initializer(group: 'group2')
  bool init2() => _inited2 = true;
  ```
- use static fields/methods(without required parameters) of a class
*NOTE:Need annotate `class name` and `field`/`method` both.*

  ```dart
  @Initializer()
  class InitA {
    @Initializer()
    static final initVar = init();

    static late final int _init;
    @Initializer()
    static int init() {
      _init = 1;
      return _init;
    }
  }
  ```
