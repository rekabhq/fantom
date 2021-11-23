// ignore_for_file: prefer_initializing_formals

class Optional<T extends Object?> {
  final T value;

  const Optional(this.value);
}

// for example ...
class User {
  final String x1; // required, not-null, no-default
  final String? x2; // required, nullable, no-default
  final String x3; // not-required, not-null, default = 'ABC'
  final String? x4; // not-required, nullable, default = 'DEF'
  final Optional<String>? x5; // not-required, not-null, no-default
  final Optional<String?>? x6; // not-required, nullable, no-default
  final String x7; // required, not-null, default = 'ABC'
  final String? x8; // required, nullable, default = 'DEF'

  User({
    required String x1,
    String? x2,
    Optional<String>? x3,
    Optional<String?>? x4,
    Optional<String>? x5,
    Optional<String?>? x6,
    required String x7,
    String? x8,
  })  : x1 = x1,
        x2 = x2,
        x3 = x3 != null ? x3.value : 'ABC',
        x4 = x4 != null ? x4.value : 'DEF',
        x5 = x5,
        x6 = x6,
        x7 = x7,
        x8 = x8;
}
