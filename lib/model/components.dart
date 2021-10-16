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

  // TODO - unit tests are required
  factory Components.fromMap(Map<String, dynamic> map) {
    // Mapping schemas object
    final schemas = map['schemas'] == null
        ? null
        : (map['schemas'] as Map<String, dynamic>).map<String, Schema>(
            (key, value) => MapEntry(key, Schema.fromMap(value)),
          );

    // Mapping responses object
    final responses = map['responses'] == null
        ? null
        : (map['responses'] as Map<String, dynamic>)
            .map<String, Referenceable<Response>>(
            (key, value) => MapEntry(
              key,
              !value.contain('\$ref')
                  ? Referenceable.left(Response.fromMap(value))
                  : Referenceable.right(Reference.fromMap(value)),
            ),
          );

    // Mapping parameters object
    final parameters = map['parameters'] == null
        ? null
        : (map['parameters'] as Map<String, dynamic>)
            .map<String, Referenceable<Parameter>>(
            (key, value) => MapEntry(
              key,
              !value.contain('\$ref')
                  ? Referenceable.left(Parameter.fromMap(value))
                  : Referenceable.right(Reference.fromMap(value)),
            ),
          );

    // Mapping requestBodies object
    final requestBodies = map['requestBodies'] == null
        ? null
        : (map['requestBodies'] as Map<String, dynamic>)
            .map<String, Referenceable<RequestBody>>(
            (key, value) => MapEntry(
              key,
              !value.contain('\$ref')
                  ? Referenceable.left(RequestBody.fromMap(value))
                  : Referenceable.right(Reference.fromMap(value)),
            ),
          );

    // Mapping headers object
    final headers = map['headers'] == null
        ? null
        : (map['headers'] as Map<String, dynamic>)
            .map<String, Referenceable<Header>>(
            (key, value) => MapEntry(
              key,
              !value.contain('\$ref')
                  ? Referenceable.left(Header.fromMap(value))
                  : Referenceable.right(Reference.fromMap(value)),
            ),
          );

    // Mapping pathItems object
    final pathItems = map['pathItems'] == null
        ? null
        : (map['pathItems'] as Map<String, dynamic>)
            .map<String, Referenceable<PathItem>>(
            (key, value) => MapEntry(
              key,
              !value.contain('\$ref')
                  ? Referenceable.left(PathItem.fromMap(value))
                  : Referenceable.right(Reference.fromMap(value)),
            ),
          );

    return Components(
      schemas: schemas,
      responses: responses,
      parameters: parameters,
      requestBodies: requestBodies,
      headers: headers,
      pathItems: pathItems,
    );
  }
}
