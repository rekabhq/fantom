part of 'model.dart';

class Optional<T extends Object?> extends Equatable {
  final T value;

  const Optional(this.value);

  @override
  List<Object?> get props => [
        value,
      ];
}
