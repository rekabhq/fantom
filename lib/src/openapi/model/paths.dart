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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Paths &&
          runtimeType == other.runtimeType &&
          mapEquals(paths, other.paths);

  @override
  int get hashCode => runtimeType.hashCode ^ mapHash(paths);
}
