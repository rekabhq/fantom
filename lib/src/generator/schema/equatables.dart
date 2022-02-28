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

I fantomEnumSerialize<V extends Object, I extends Object>({
  required final List<V> values,
  required final List<I> items,
  required final V value,
}) {
  final length = items.length;
  for (var index = 0; index < length; index++) {
    if (values[index] == value) {
      return items[index];
    }
  }
  throw AssertionError('enum serialization: not found value.');
}

V fantomEnumDeserialize<V extends Object, I extends Object>({
  required final List<V> values,
  required final List<I> items,
  required final I item,
}) {
  final length = items.length;
  for (var index = 0; index < length; index++) {
    if (fantomEquals(items[index], item)) {
      return values[index];
    }
  }
  throw AssertionError('enum deserialization: not found item.');
}
