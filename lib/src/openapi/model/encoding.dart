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

  factory Encoding.fromMap(Map<String, dynamic> map) => Encoding(
        contentType: map['contentType'],
        headers: (map['headers'] as Map<String, dynamic>?)?.mapValues(
          (e) => Referenceable.fromMap(
            e,
            builder: (m) => Header.fromMap(m),
          ),
        ),
        style: map['style'],
        explode: map['explode'],
        allowReserved: map['allowReserved'],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Encoding &&
          runtimeType == other.runtimeType &&
          contentType == other.contentType &&
          mapEquals(headers, other.headers) &&
          style == other.style &&
          explode == other.explode &&
          allowReserved == other.allowReserved;

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      contentType.hashCode ^
      mapHash(headers) ^
      style.hashCode ^
      explode.hashCode ^
      allowReserved.hashCode;
}
