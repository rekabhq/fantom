part of 'model.dart';

class Responses {
  /// described as [default] in documentation.
  /// but [default], is a keyword in Dart.
  final Referenceable<Response>? other;

  /// other key-value pairs
  final Map<String, Referenceable<Response>>? map;

  const Responses({
    required this.other,
    required this.map,
  });

  factory Responses.fromMap(Map<String, dynamic> map) {
    // TODO: implement method
    throw UnimplementedError();
  }
}
