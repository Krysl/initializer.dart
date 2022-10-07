import 'package:initializer_annotation/initializer_annotation.dart';

class Settings {
  final ClassConfig config;

  Settings({
    Initializer? config,
  }) : config = config != null
            ? ClassConfig.fromInitializer(config)
            : ClassConfig.defaults;
}

class ClassConfig {
  final bool debug;
  final String group;
  final String outputPath;
  const ClassConfig({
    required this.debug,
    required this.group,
    required this.outputPath,
  });

  factory ClassConfig.fromInitializer(Initializer config) =>
      // #CHANGE WHEN UPDATING json_annotation
      ClassConfig(
        debug: config.debug,
        group: config.group ?? defaults.group,
        outputPath: config.outputPath ?? defaults.outputPath,
      );
  static const defaults = ClassConfig(
    debug: false,
    group: 'default',
    outputPath: 'lib/src/init.init.dart',
  );

  Initializer toInitializer() => Initializer(group: group);
}
