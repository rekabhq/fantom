part of 'model.dart';

class Operation {
  final List<Referenceable<Parameter>>? parameters;

  final Referenceable<RequestBody>? requestBody;

  final String? operationId;

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
    required this.operationId,
  });

  factory Operation.fromMap(Map<String, dynamic> map) => Operation(
        parameters: (map['parameters'] as List<dynamic>?)?.mapToList(
          (e) => Referenceable.fromMap(
            e,
            builder: (m) => Parameter.fromMap(m),
          ),
        ),
        requestBody: map['requestBody'] == null
            ? null
            : Referenceable.fromMap(
                map['requestBody'],
                builder: (m) => RequestBody.fromMap(m),
              ),
        responses: map['responses'] == null
            ? null
            : Responses.fromMap(map['responses']),
        deprecated: map['deprecated'],
        hasSecurity: map['security'] != null &&
            (map['security'] as Map<String, dynamic>).isNotEmpty,
        operationId: map['operationId'],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Operation &&
          runtimeType == other.runtimeType &&
          listEquals(parameters, other.parameters) &&
          requestBody == other.requestBody &&
          operationId == other.operationId &&
          responses == other.responses &&
          deprecated == other.deprecated &&
          hasSecurity == other.hasSecurity;

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      listHash(parameters) ^
      requestBody.hashCode ^
      operationId.hashCode ^
      responses.hashCode ^
      deprecated.hashCode ^
      hasSecurity.hashCode;
}
