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
            (key, value) => MapEntry(key, Schema.fromMap(map)),
          );

    // Mapping responses object
    final responses = map['responses'] == null
        ? null
        : (map['responses'] as Map<String, dynamic>)
            .map<String, Referenceable<Response>>(
            (key, value) => MapEntry(
              key,
              !value.contain('\$ref')
                  ? Referenceable.left(Response.fromMap(map))
                  : Referenceable.right(Reference.fromMap(map)),
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
                  ? Referenceable.left(Parameter.fromMap(map))
                  : Referenceable.right(Reference.fromMap(map)),
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
                  ? Referenceable.left(RequestBody.fromMap(map))
                  : Referenceable.right(Reference.fromMap(map)),
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
                  ? Referenceable.left(Header.fromMap(map))
                  : Referenceable.right(Reference.fromMap(map)),
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
                  ? Referenceable.left(PathItem.fromMap(map))
                  : Referenceable.right(Reference.fromMap(map)),
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
