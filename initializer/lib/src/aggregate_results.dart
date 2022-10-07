// ignore_for_file: implementation_imports, unnecessary_import
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

abstract class AggregateResults {
  final Map<Uri, Set<String>> _sourceMap = {};
  abstract final String path;

  @mustCallSuper
  void merge(covariant AggregateResults other) {
    for (final kv in other._sourceMap.entries) {
      final src = kv.key;
      final nameList = kv.value;

      if (_sourceMap.containsKey(src)) {
        _sourceMap[src]!.addAll(nameList);
      } else {
        _sourceMap[src] = nameList;
      }
    }
  }

  @override
  String toString();
  void addSourceMap(Uri src, String name) {
    if (_sourceMap.containsKey(src)) {
      _sourceMap[src]!.add(name);
    } else {
      _sourceMap[src] = {name};
    }
  }
}

class AggregateResultsGroup {
  final Map<String, AggregateResults> _groups;
  final String rootPackage;
  final String outputPath;
  final Set<String>? order;
  AggregateResultsGroup({
    Map<String, AggregateResults>? groups,
    required this.rootPackage,
    required this.outputPath,
    required this.order,
  }) : _groups = groups ?? <String, AggregateResults>{};

  void addGroup(String group, AggregateResults result) {
    if (_groups.containsKey(group)) {
      _groups[group]!.merge(result);
    } else {
      _groups[group] = result;
    }
  }

  void addAll(Map<String, AggregateResults>? all) {
    if (all == null) return;
    for (final kv in all.entries) {
      addGroup(kv.key, kv.value);
    }
  }

  Map<Uri, Set<String>> mergeSourceMap() {
    final sourceMap = <Uri, Set<String>>{};
    for (final kv in _groups.entries) {
      final results = kv.value;
      final srcMap = results._sourceMap;
      for (final srcPair in srcMap.entries) {
        final source = srcPair.key;
        final nameList = srcPair.value;
        if (sourceMap.containsKey(source)) {
          sourceMap[source]!.addAll(nameList);
        } else {
          sourceMap[source] = nameList;
        }
      }
    }
    return sourceMap;
  }

  @override
  String toString() {
    final strbuf = StringBuffer();
    final groupNames = <String>[];

    final srcMap = mergeSourceMap();
    for (final pair in srcMap.entries) {
      final src = pair.key;
      final nameList = pair.value;
      String? importPath;
      String? srcPath;
      switch (src.scheme) {
        case 'asset':
          srcPath = src.path;
          break;
        case 'package':
          srcPath = src.path.replaceFirst(rootPackage, '$rootPackage/lib');
          break;
      }
      final relativePath = p.dirname(p.join(rootPackage, outputPath));

      importPath = p
          .relative(
            srcPath!,
            from: relativePath,
          )
          .replaceAll(r'\', r'/');

      strbuf.writeln("import '$importPath' show ${nameList.join(', ')};");
    }
    strbuf.writeln();
    for (final kv in _groups.entries) {
      final groupName = kv.key;
      final aggregateResults = kv.value;

      strbuf.writeln(aggregateResults.toString());
      groupNames.add(groupName);
    }
    strbuf.write('void initializer(');
    if (groupNames.isNotEmpty) strbuf.writeln('{');
    for (final groupName in groupNames) {
      strbuf.writeln('  bool enable$groupName = true,');
    }
    if (groupNames.isNotEmpty) strbuf.write('}');
    strbuf.writeln(') {');
    if (order != null && order!.isNotEmpty) {
      final groupNameOrder = order!.toList();
      groupNames.sort(
        (a, b) {
          const intMax = 0x7fffffffffffffff;
          var aIndex = groupNameOrder.indexOf(a);
          if (aIndex < 0) aIndex = intMax;
          var bIndex = groupNameOrder.indexOf(b);
          if (bIndex < 0) bIndex = intMax;
          return aIndex.compareTo(bIndex);
        },
      );
    }
    for (final groupName in groupNames) {
      strbuf.writeln('  if(enable$groupName) ${groupName}Initializer();');
    }
    strbuf.writeln('}');

    return strbuf.toString();
  }
}
