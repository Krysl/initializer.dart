import 'package:json_annotation/json_annotation.dart';

part 'initializer.g.dart';

@JsonSerializable(
  checked: true,
  disallowUnrecognizedKeys: true,
  fieldRename: FieldRename.snake,
)
class Initializer {
  final String? group;
  final String? outputPath;

  const Initializer({
    this.group,
    this.outputPath,
  });

  factory Initializer.fromJson(Map<String, dynamic> json) =>
      _$InitializerFromJson(json);

  Map<String, dynamic> toJson() => _$InitializerToJson(this);
}
