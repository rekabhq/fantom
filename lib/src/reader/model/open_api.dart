part of 'model.dart';

class OpenApi extends Equatable {
  final String openapi;

  /// path object is required in v3.0.0
  final Paths paths;

  final Components? components;

  const OpenApi({
    required this.openapi,
    required this.paths,
    required this.components,
  });

  factory OpenApi.fromMap(Map<String, dynamic> map) => OpenApi(
        openapi: map['openapi'],
        paths: Paths.fromMap(map['paths']),
        components: map['components'] == null
            ? null
            : Components.fromMap(map['components']),
      );

  @override
  List<Object?> get props => [
        openapi,
        paths,
        components,
      ];

  @override
  String toString() => 'OpenApi{openapi: $openapi, '
      'paths: $paths, components: $components}';
}

extension OpenApiExt on OpenApi {
  Version get version => Version.parse(openapi);
}
