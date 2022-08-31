part of 'model.dart';

class Responses extends Equatable {
  /// described as [default] in openapi specification.
  /// but [default], is a keyword in Dart.
  final ReferenceOr<Response>? defaultValue;

  /// other key-value pairs
  final Map<String, ReferenceOr<Response>>? map;

  const Responses({
    required this.defaultValue,
    required this.map,
  });

  factory Responses.fromMap(Map<String, dynamic> map) {
    final all = map.mapValues(
      (e) => ReferenceOr.fromMap(
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

  Map<String, ReferenceOr<Response>> get allResponses {
    final value = <String, ReferenceOr<Response>>{};
    if (defaultValue != null) {
      value['default'] = defaultValue!;
    }
    if (map != null) {
      value.addAll(map!);
    }
    return value;
  }

  @override
  List<Object?> get props => [
        defaultValue,
        map,
      ];

  @override
  String toString() => 'Responses{defaultValue: $defaultValue, '
      'map: $map}';
}
