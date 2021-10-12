part of 'model.dart';

class Reference<T extends Object> {
  final String ref;

  const Reference({
    required this.ref,
  });
}

typedef Referenceable<T extends Object> = Either<T, Reference<T>>;
