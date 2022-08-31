part of 'model.dart';

class Encoding extends Equatable {
  final String? contentType;

  final Map<String, ReferenceOr<Header>>? headers;

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
          (e) => ReferenceOr.fromMap(
            e,
            builder: (m) => Header.fromMap(m),
          ),
        ),
        style: map['style'],
        explode: map['explode'],
        allowReserved: map['allowReserved'],
      );

  @override
  List<Object?> get props => [
        contentType,
        headers,
        style,
        explode,
        allowReserved,
      ];

  @override
  String toString() => 'Encoding{contentType: $contentType, headers: $headers, '
      'style: $style, explode: $explode, allowReserved: $allowReserved}';
}
