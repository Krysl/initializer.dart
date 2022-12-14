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
  final Set<String> order;
  const ClassConfig({
    required this.debug,
    required this.group,
    required this.outputPath,
    required this.order,
  });

  factory ClassConfig.fromInitializer(Initializer config) =>
      // #CHANGE WHEN UPDATING initializer_annotation
      ClassConfig(
        debug: config.debug,
        group: config.group ?? defaults.group,
        outputPath: config.outputPath ?? defaults.outputPath,
        order: config.order ?? defaults.order,
      );
  static const defaults = ClassConfig(
    debug: false,
    group: 'default',
    outputPath: 'lib/src/init.init.dart',
    order: <String>{},
  );

  Initializer toInitializer() => Initializer(group: group);
}
