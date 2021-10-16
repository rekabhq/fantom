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

  // TODO - unit tests are required
  factory OpenApi.fromMap(Map<String, dynamic> map) {
    Paths? paths;
    Components? components;
    if (map.containsKey('paths')) {
      paths = Paths.fromMap(map['paths']);
    }
    if (map.containsKey('components')) {
      components = Components.fromMap(map['components']);
    }

    return OpenApi(
      openapi: map['openapi'],
      paths: paths,
      components: components,
    );
  }
}
