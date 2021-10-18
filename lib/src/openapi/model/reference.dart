part of 'model.dart';

class Reference<T extends Object> {
  final String ref;

  const Reference({
    required this.ref,
  });

  factory Reference.fromMap(Map<String, dynamic> map) {
    return Reference(ref: map['\$ref']);
  }

  static bool isReferenceMap(Map<String, dynamic> map) {
    return map['\$ref'] is String;
  }
}
