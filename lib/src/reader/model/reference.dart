part of 'model.dart';

class Reference<T extends Object> extends Equatable {
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
  List<Object?> get props => [
        ref,
      ];

  @override
  String toString() => 'Reference{ref: $ref}';
}
