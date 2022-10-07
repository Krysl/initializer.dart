import 'package:initializer_annotation/initializer_annotation.dart';

@Initializer()
final initVar = init();

late final bool _inited;
bool get inited => _inited;

@Initializer(group: 'group1')
bool init() => _inited = true;

@Initializer(group: 'group2')
bool init2() => _inited = true;

@Initializer(group: 'group1')
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
