part of 'model.dart';

class OpenApi {
  final String version;

  final Paths? paths;

  final Components? components;

  const OpenApi({
    required this.version,
    required this.paths,
    required this.components,
  });

  factory OpenApi.fromMap(Map<String, dynamic> map) => OpenApi(
        version: map['openapi'],
        paths: map['paths'] == null ? null : Paths.fromMap(map['paths']),
        components: map['components'] == null
            ? null
            : Components.fromMap(map['components']),
      );
}
