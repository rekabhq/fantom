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

  factory Components.fromMap(Map<String, dynamic> map) => Components(
        schemas: (map['schemas'] as Map<String, dynamic>?)?.mapValues(
          (e) => Schema.fromMap(e),
        ),
        responses: (map['responses'] as Map<String, dynamic>?)?.mapValues(
          (e) => Referenceable.fromMap(
            e,
            builder: (m) => Response.fromMap(m),
          ),
        ),
        parameters: (map['parameters'] as Map<String, dynamic>?)?.mapValues(
          (e) => Referenceable.fromMap(
            e,
            builder: (m) => Parameter.fromMap(m),
          ),
        ),
        requestBodies:
            (map['requestBodies'] as Map<String, dynamic>?)?.mapValues(
          (e) => Referenceable.fromMap(
            e,
            builder: (m) => RequestBody.fromMap(m),
          ),
        ),
        headers: (map['headers'] as Map<String, dynamic>?)?.mapValues(
          (e) => Referenceable.fromMap(
            e,
            builder: (m) => Header.fromMap(m),
          ),
        ),
        pathItems: (map['pathItems'] as Map<String, dynamic>?)?.mapValues(
          (e) => Referenceable.fromMap(
            e,
            builder: (m) => PathItem.fromMap(m),
          ),
        ),
      );
}
