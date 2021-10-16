part of 'model.dart';

class Operation {
  final List<Referenceable<Parameter>>? parameters;

  final Referenceable<RequestBody>? requestBody;

  final Responses? responses;

  final bool? deprecated;

  /// we only check if security	is not empty
  final bool hasSecurity;

  const Operation({
    required this.parameters,
    required this.requestBody,
    required this.responses,
    required this.deprecated,
    required this.hasSecurity,
  });

  factory Operation.fromMap(Map<String, dynamic> map) => Operation(
        parameters: (map['parameters'] as List<dynamic>?)?.mapToList(
          (e) => Referenceable.fromMap(
            e,
            builder: (m) => Parameter.fromMap(m),
          ),
        ),
        requestBody: map['responses'] == null
            ? null
            : Referenceable.fromMap(
                map['responses'],
                builder: (m) => RequestBody.fromMap(m),
              ),
        responses: map['responses'] == null
            ? null
            : Responses.fromMap(map['responses']),
        deprecated: map['deprecated'],
        hasSecurity: map['security'] != null,
      );
}
