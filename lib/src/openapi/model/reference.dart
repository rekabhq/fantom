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

class Referenceable<T extends Object> {
  final T? _value;

  final Reference<T>? _reference;

  const Referenceable.value(T value)
      : _value = value,
        _reference = null;

  const Referenceable.reference(Reference<T> reference)
      : _value = null,
        _reference = reference;

  bool get isValue => _value != null;

  T get value => _value!;

  T? get valueOrNull => _value;

  bool get isRight => _reference != null;

  Reference<T> get reference => _reference!;

  Reference<T>? get referenceOrNull => _reference;

  R match<R extends Object?>({
    required R Function(T value) value,
    required R Function(Reference<T> reference) reference,
  }) =>
      _value != null ? value(_value!) : reference(_reference!);

  factory Referenceable.fromMap(
    Map<String, dynamic> map, {
    required T Function(Map<String, dynamic> map) builder,
  }) =>
      Reference.isReferenceMap(map)
          ? Referenceable<T>.reference(Reference<T>.fromMap(map))
          : Referenceable<T>.value(builder(map));
}
