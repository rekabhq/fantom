import 'package:equatable/equatable.dart';

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
