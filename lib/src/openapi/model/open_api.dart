part of 'model.dart';

class OpenApi {
  final String openapi;

  final Paths? paths;

  final Components? components;

  const OpenApi({
    required this.openapi,
    required this.paths,
    required this.components,
  });

  factory OpenApi.fromMap(Map<String, dynamic> map) => OpenApi(
        openapi: map['openapi'],
        paths: map['paths'] == null ? null : Paths.fromMap(map['paths']),
        components: map['components'] == null
            ? null
            : Components.fromMap(map['components']),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpenApi &&
          runtimeType == other.runtimeType &&
          openapi == other.openapi &&
          paths == other.paths &&
          components == other.components;

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      openapi.hashCode ^
      paths.hashCode ^
      components.hashCode;
}
