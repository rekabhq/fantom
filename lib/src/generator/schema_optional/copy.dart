// ignore_for_file: unused_element, dead_code, prefer_initializing_formals

import 'package:equatable/equatable.dart';

class Optional<T extends Object?> extends Equatable {
  final T value;

  const Optional(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Optional($value)';
}

extension OptionalWrappingExt<T extends Object?> on T {
  Optional<T> get opt => Optional(this);
}

extension OptionalUnwrappingExt<T extends Object?> on Optional<T>? {
  T? get orNull => this?.value;
}

// todo: uie, sets ?
bool fantomEquals(
  final Object? value1,
  final Object? value2,
) {
  return FantomEqualityModel(value1) == FantomEqualityModel(value2);
}

class FantomEqualityModel extends Equatable {
  final Object? value;

  const FantomEqualityModel(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'FantomEqualityModel($value)';
}
