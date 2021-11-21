import 'package:fantom/src/utils/exceptions.dart';

typedef OperationName = String;
typedef PathValue = String;

class ExcludedPaths {
  final Map<PathValue, List<OperationName>> paths;

  ExcludedPaths._(this.paths);

  factory ExcludedPaths.fromFantomConfigValues(List<String> values) {
    final map = <PathValue, List<OperationName>>{};
    for (var configValue in values) {
      try {
        final splitted = configValue.split('--').map((e) => e.trim());
        final path = splitted.first;
        List<String> operations = [];
        if (splitted.length > 1) {
          operations = splitted.last
              .replaceAll('[', '')
              .replaceAll(']', '')
              .split(',')
              .map((e) => e.trim())
              .toList();
        }
        map[path] = operations;
      } catch (e, _) {
        throw InvalidExcludedPathException(configValue);
      }
    }
    return ExcludedPaths._(map);
  }

  @override
  String toString() => paths.toString();
}

/// a method to check the values of the excluded components added to fantom config file
void checkExcludedComponentsValues(List<String> exclusions) {
  for (var componentName in exclusions) {
    if (!componentName.startsWith('components/')) {
      throw InvalidExcludedComponent(componentName);
    }
  }
}
