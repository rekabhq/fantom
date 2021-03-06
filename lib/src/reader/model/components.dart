part of 'model.dart';

class Components extends Equatable {
  final Map<String, Referenceable<Schema>>? schemas;

  final Map<String, Referenceable<Response>>? responses;

  final Map<String, Referenceable<Parameter>>? parameters;

  final Map<String, Referenceable<RequestBody>>? requestBodies;

  final Map<String, Referenceable<Header>>? headers;

  // we don't have path items in v3.0.0

  const Components({
    required this.schemas,
    required this.responses,
    required this.parameters,
    required this.requestBodies,
    required this.headers,
  });

  factory Components.fromMap(Map<String, dynamic> map) => Components(
        schemas: (map['schemas'] as Map<String, dynamic>?)?.mapValues(
          (e) => Referenceable.fromMap(
            e,
            builder: (m) => Schema.fromMap(m),
          ),
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
      );

  @override
  List<Object?> get props => [
        schemas,
        responses,
        parameters,
        requestBodies,
        headers,
      ];

  @override
  String toString() => 'Components{schemas: $schemas, responses: $responses, '
      'parameters: $parameters, requestBodies: $requestBodies, '
      'headers: $headers}';
}
