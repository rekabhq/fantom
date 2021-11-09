// ignore_for_file: unused_element

import 'package:equatable/equatable.dart';

class Optional<T extends Object?> extends Equatable {
  final T value;

  const Optional(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Optional($value)';
}

extension OptionalExt<T extends Object?> on T {
  Optional<T> get opt => Optional(this);
}

bool _equals(
  final Object? value1,
  final Object? value2,
) {
  return _Equals(value1) == _Equals(value2);
}

class _Equals extends Equatable {
  final Object? value;

  const _Equals(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => '_Equals($value)';
}
