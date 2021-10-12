part of 'model.dart';

class Responses {
  /// described as [default] in documentation.
  /// but in, is a keyword in Dart.
  final Response? other;

  /// other key-value pairs
  final Map<String, Response>? map;

  const Responses({
    required this.other,
    required this.map,
  });
}
