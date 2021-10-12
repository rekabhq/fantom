part of 'model.dart';

class Responses {
  /// described as [default] in documentation.
  /// but in, is a keyword in Dart.
  final Referenceable<Response>? other;

  /// other key-value pairs
  final Map<String, Referenceable<Response>>? map;

  const Responses({
    required this.other,
    required this.map,
  });
}
