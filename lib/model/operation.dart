part of 'model.dart';

class Operation {
  final List<Parameter>? parameters;

  final RequestBody? requestBody;

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
}
