part of 'model.dart';

class Paths {
  final Map<String, PathItem> paths;

  Paths({
    required this.paths,
  });

  factory Paths.fromMap(Map<String, dynamic> map) {
    // this is a required parameter so if we have a null paths object we will get a error
    final paths = map.map<String, PathItem>(
      (key, value) => MapEntry(key, PathItem.fromMap(value)),
    );

    return Paths(paths: paths);
  }
}
