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

// typedef Referenceable<T extends Object> = Either<T, Reference<T>>;

class Referenceable<T extends Object> extends Either<T, Reference<T>> {
  Referenceable.value(T left) : super.left(left);
  Referenceable.reference(Reference<T> reference) : super.right(reference);

  // factory ReferenceOr.fromMap(Map<String, dynamic> map) {
  //   if (map.containsKey('\$ref')) {
  //     return ReferenceOr.reference(Reference.fromMap(map));
  //   }else{
  //     return 
  //   }
  // }
}
