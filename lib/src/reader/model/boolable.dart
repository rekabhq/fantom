part of 'model.dart';

class Boolable<T extends Object> extends Equatable {
  final T? _value;

  final bool? _boolean;

  const Boolable.value(T value)
      : _value = value,
        _boolean = null;

  const Boolable.boolean(bool boolean)
      : _value = null,
        _boolean = boolean;

  bool get isValue => _value != null;

  T get value => _value!;

  T? get valueOrNull => _value;

  bool get isBoolean => _boolean != null;

  bool get boolean => _boolean!;

  bool? get booleanOrNull => _boolean;

  R match<R extends Object?>({
    required R Function(T value) value,
    required R Function(bool boolean) boolean,
  }) =>
      _value != null ? value(_value!) : boolean(_boolean!);

  factory Boolable.fromMap(
    final dynamic json, {
    required final T Function(dynamic json) builder,
  }) =>
      json is bool
          ? Boolable<T>.boolean(json)
          : Boolable<T>.value(builder(json));

  @override
  List<Object?> get props => [
        _value,
        _boolean,
      ];

  @override
  String toString() => _value != null
      ? 'Boolable.value{$_value}'
      : 'Boolable.boolean{$_boolean}';
}
