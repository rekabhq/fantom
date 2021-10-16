part of 'model.dart';

class Responses {
  /// described as [default] in documentation.
  /// but [default], is a keyword in Dart.
  final Referenceable<Response>? defaultValue;

  /// other key-value pairs
  final Map<String, Referenceable<Response>>? map;

  const Responses({
    required this.defaultValue,
    required this.map,
  });

  factory Responses.fromMap(Map<String, dynamic> map) {
    final all = map.mapValues(
      (e) => Referenceable.fromMap(
        e,
        builder: (m) => Response.fromMap(m),
      ),
    );
    // removing `default` from responses
    final other = all.remove('default');

    return Responses(
      defaultValue: other,
      map: all,
    );
  }
}
