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

  factory OpenApi.fromMap(Map<String, dynamic> map) {
    // TODO: implement method
    throw UnimplementedError();
  }
}
