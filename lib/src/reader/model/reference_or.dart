part of 'model.dart';

class ReferenceOr<T extends Object> extends Equatable {
  final T? _value;

  final Reference<T>? _reference;

  const ReferenceOr.value(T value)
      : _value = value,
        _reference = null;

  const ReferenceOr.reference(Reference<T> reference)
      : _value = null,
        _reference = reference;

  bool get isValue => _value != null;

  T get value => _value!;

  T? get valueOrNull => _value;

  bool get isReference => _reference != null;

  Reference<T> get reference => _reference!;

  Reference<T>? get referenceOrNull => _reference;

  R match<R extends Object?>({
    required R Function(T value) value,
    required R Function(Reference<T> reference) reference,
  }) =>
      _value != null ? value(_value!) : reference(_reference!);

  factory ReferenceOr.fromMap(
    dynamic map, {
    required T Function(dynamic json) builder,
  }) =>
      Reference.isReferenceMap(map)
          ? ReferenceOr<T>.reference(Reference<T>.fromMap(map))
          : ReferenceOr<T>.value(builder(map));

  @override
  List<Object?> get props => [
        _value,
        _reference,
      ];

  @override
  String toString() => _value != null
      ? 'Referenceable.value{$_value}'
      : 'Referenceable.reference{$_reference}';
}
