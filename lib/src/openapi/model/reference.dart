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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reference &&
          runtimeType == other.runtimeType &&
          ref == other.ref;

  @override
  int get hashCode => runtimeType.hashCode ^ ref.hashCode;
}
