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

  User({
    required String x1,
    required String? x2,
    required Optional<String>? x3,
    required Optional<String?>? x4,
    required Optional<String>? x5,
    required Optional<String?>? x6,
  })  : x1 = x1,
        x2 = x2,
        x3 = x3 != null ? x3.value : 'ABC',
        x4 = x4 != null ? x4.value : 'DEF',
        x5 = x5,
        x6 = x6;
}

class User$ {
  // can add:
  //
  // assert(json is Map<String, dynamic>);
  //
  // assert(json.containsKey('x1'));
  // assert(json.containsKey('x2'));
  static User fromJson(dynamic json) => User(
        x1: json['x1'],
        x2: json['x2'],
        x3: json.containsKey('x3') ? Optional(json['x3']) : null,
        x4: json.containsKey('x4') ? Optional(json['x4']) : null,
        x5: json.containsKey('x5') ? Optional(json['x5']) : null,
        x6: json.containsKey('x6') ? Optional(json['x6']) : null,
      );

  static dynamic toJson(User value) => <String, dynamic>{
        'x1': value.x1,
        'x2': value.x2,
        'x3': value.x3,
        'x4': value.x4,
        if (value.x5 != null) 'x5': value.x5!.value,
        if (value.x6 != null) 'x5': value.x6!.value,
      };

  // can add:
  //
  // assert(json is List<dynamic>);
  static List<User> fromJsonList(dynamic json) => json.map(fromJson).toList();

  dynamic toJsonList(List<User> value) => value.map(toJson).toList();

  static MapEntry<String, User> fromJsonEntry(String key, dynamic json) =>
      MapEntry(key, fromJson(json));

  // can add:
  //
  // assert(json is Map<String, dynamic>);
  static Map<String, User> fromJsonMap(dynamic json) => json.map(fromJsonEntry);

  static MapEntry<String, dynamic> toJsonEntry(String key, User value) =>
      MapEntry(key, toJson(value));

  static dynamic toJsonMap(Map<String, User> value) => value.map(toJsonEntry);
}
