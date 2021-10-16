part of 'model.dart';

class Encoding {
  final String? contentType;

  final Map<String, Referenceable<Header>>? headers;

  final String? style;

  final bool? explode;

  final bool? allowReserved;

  const Encoding({
    required this.contentType,
    required this.headers,
    required this.style,
    required this.explode,
    required this.allowReserved,
  });

  // TODO - unit tests are required
  factory Encoding.fromMap(Map<String, dynamic> map) {
    final headers = map['headers'] == null
        ? null
        : (map['headers'] as Map<String, dynamic>).map<String, Referenceable<Header>>(
            (key, value) => MapEntry(
              key,
              !value.contain('\$ref')
                  ? Referenceable.left(Header.fromMap(value))
                  : Referenceable.right(Reference.fromMap(value)),
            ),
          );

    return Encoding(
      contentType: map['contentType'],
      headers: headers,
      style: map['style'],
      explode: map['explode'],
      allowReserved: map['allowReserved'],
    );
  }
}
