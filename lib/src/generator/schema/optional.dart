import 'package:equatable/equatable.dart';

class Optional<T extends Object?> extends Equatable {
  final T value;

  const Optional(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Optional($value)';
}
