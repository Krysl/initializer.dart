// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Configuration for using `package:build`-compatible build systems.
///
/// See:
/// * [build_runner](https://pub.dev/packages/build_runner)
///
/// This library is **not** intended to be imported by typical end-users unless
/// you are creating a custom compilation pipeline. See documentation for
/// details, and `build.yaml` for how these builders are configured by default.
library initializer.builder;

import 'package:build/build.dart';
import 'package:initializer_annotation/initializer_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'src/aggregate_builder.dart';
import 'src/initializer_generator.dart';
// import 'src/part_builder.dart';
import 'src/settings.dart';

/// Supports `package:build_runner` creation and configuration of
/// `initializer`.
///
/// Not meant to be invoked by hand-authored code.
Builder initializer(BuilderOptions options) {
  try {
    final config = Initializer.fromJson(options.config);
    final settings = Settings(config: config);
    // return partBuilder(config: config);
    return AggregateBuilder(
      outputPath: settings.config.outputPath,
      generators: [
        InitializerGenerator.fromSettings(settings),
      ],
    );
  } on CheckedFromJsonException catch (e) {
    final lines = <String>[
      'Could not parse the options provided for `initializer`.'
    ];

    if (e.key != null) {
      lines.add('There is a problem with "${e.key}".');
    }
    if (e.message != null) {
      lines.add(e.message!);
    } else if (e.innerError != null) {
      lines.add(e.innerError.toString());
    }

    throw StateError(lines.join('\n'));
  }
}
