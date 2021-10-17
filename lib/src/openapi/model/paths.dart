part of 'model.dart';

class Paths {
  final Map<String, PathItem> paths;

  Paths({
    required this.paths,
  });

  factory Paths.fromMap(Map<String, dynamic> map) => Paths(
        paths: map.mapValues(
          (e) => PathItem.fromMap(e),
        ),
      );
}
