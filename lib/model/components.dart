part of 'model.dart';

class Components {
  final Map<String, Schema>? schemas;

  final Map<String, Response>? responses;

  final Map<String, Parameter>? parameters;

  final Map<String, RequestBody>? requestBodies;

  final Map<String, Header>? headers;

  final Map<String, PathItem>? pathItems;

  Components({
    required this.schemas,
    required this.responses,
    required this.parameters,
    required this.requestBodies,
    required this.headers,
    required this.pathItems,
  });
}
