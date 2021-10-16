part of 'model.dart';

class Paths {
  final Map<String, PathItem> paths;

  Paths({
    required this.paths,
  });

  factory Paths.fromMap(Map<String, dynamic> map) => Paths(
        paths: (map['paths'] as Map<String, dynamic>).mapValues(
          (e) => PathItem.fromMap(e),
        ),
      );
}
