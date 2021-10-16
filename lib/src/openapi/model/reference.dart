part of 'model.dart';

class Reference<T extends Object> {
  final String ref;

  const Reference({
    required this.ref,
  });

  factory Reference.fromMap(Map<String, dynamic> map) {
    return Reference(ref: map['\$ref']);
  }
}

typedef Referenceable<T extends Object> = Either<T, Reference<T>>;
