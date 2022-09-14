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
  final String group;
  final String outputPath;
  const ClassConfig({
    required this.group,
    required this.outputPath,
  });

  factory ClassConfig.fromInitializer(Initializer config) =>
      // #CHANGE WHEN UPDATING json_annotation
      ClassConfig(
        group: config.group ?? defaults.group,
        outputPath: config.outputPath ?? defaults.outputPath,
      );
  static const defaults = ClassConfig(
    group: 'default',
    outputPath: 'lib/src/init.initializer.dart',
  );

  Initializer toInitializer() => Initializer(group: group);
}
