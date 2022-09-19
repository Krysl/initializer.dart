// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initializer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Initializer _$InitializerFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Initializer',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const ['debug', 'group', 'output_path'],
        );
        final val = Initializer(
          debug: $checkedConvert('debug', (v) => v as bool? ?? false),
          group: $checkedConvert('group', (v) => v as String?),
          outputPath: $checkedConvert('output_path', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {'outputPath': 'output_path'},
    );

Map<String, dynamic> _$InitializerToJson(Initializer instance) =>
    <String, dynamic>{
      'debug': instance.debug,
      'group': instance.group,
      'output_path': instance.outputPath,
    };
