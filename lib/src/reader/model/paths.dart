part of 'model.dart';

class Paths extends Equatable {
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
  List<Object?> get props => [
        paths,
      ];

  @override
  String toString() => 'Paths{paths: $paths}';
}
