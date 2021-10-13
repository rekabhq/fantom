part of 'model.dart';

class Components {
  final Map<String, Schema>? schemas;

  final Map<String, Referenceable<Response>>? responses;

  final Map<String, Referenceable<Parameter>>? parameters;

  final Map<String, Referenceable<RequestBody>>? requestBodies;

  final Map<String, Referenceable<Header>>? headers;

  final Map<String, Referenceable<PathItem>>? pathItems;

  const Components({
    required this.schemas,
    required this.responses,
    required this.parameters,
    required this.requestBodies,
    required this.headers,
    required this.pathItems,
  });

  factory Components.fromMap(Map<String, dynamic> map) {
    // TODO: implement method
    throw UnimplementedError();
  }
}
