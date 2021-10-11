part of 'model.dart';

class Responses {
  /// renamed from `default`.
  /// since this is a keyword in dart.
  final Response? common;

  /// other key-value pairs
  final Map<String, Response>? fields;

  const Responses({
    required this.common,
    required this.fields,
  });
}
