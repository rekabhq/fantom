part of 'model.dart';

class OpenApi extends Equatable {
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
  List<Object?> get props => [
        openapi,
        paths,
        components,
      ];
}

extension OpenApiExt on OpenApi {
  Version get version => Version.parse(openapi);
}
