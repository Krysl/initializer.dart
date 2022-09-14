import 'package:initializer_annotation/initializer_annotation.dart';

@Initializer()
final bool initA = fnInitA();

bool fnInitA() => true;
