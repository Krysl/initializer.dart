import 'package:json_annotation/json_annotation.dart';

part 'initializer.g.dart';

@JsonSerializable(
  checked: true,
  disallowUnrecognizedKeys: true,
  fieldRename: FieldRename.snake,
)
class Initializer {
  final bool debug;
  final String? group;
  final String? outputPath;
  final Set<String>? order;

  const Initializer({
    this.debug = false,
    this.group,
    this.outputPath,
    this.order,
  });

  factory Initializer.fromJson(Map<String, dynamic> json) =>
      _$InitializerFromJson(json);

  Map<String, dynamic> toJson() => _$InitializerToJson(this);
}
