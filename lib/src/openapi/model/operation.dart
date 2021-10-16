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

  factory Operation.fromMap(Map<String, dynamic> map) {
    // Mapping parameters object
    final parameters = map["parameters"] == null
        ? null
        : List<Referenceable<Parameter>>.from(
            map["parameters"].map<Referenceable<Parameter>>(
              (value) => !value.containsKey('\$ref')
                  ? Referenceable.value(Parameter.fromMap(value))
                  : Referenceable.reference(Reference.fromMap(value)),
            ),
          );

    // Mapping requestBody object
    final requestBody = map["requestBody"] == null
        ? null
        : map["requestBody"].contain('\$ref')
            ? Referenceable<RequestBody>.value(
                RequestBody.fromMap(map["requestBody"]),
              )
            : Referenceable<RequestBody>.reference(
                Reference.fromMap(map["requestBody"]),
              );

    // Mapping responses object
    final responses =
        map['responses'] == null ? null : Responses.fromMap(map['responses']);

    return Operation(
      parameters: parameters,
      requestBody: requestBody,
      responses: responses,
      deprecated: map['deprecated'],
      hasSecurity: map['security'] != null,
    );
  }
}
