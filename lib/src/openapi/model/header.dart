part of 'model.dart';

class Header {
  /// described as [required] in openapi documentation
  /// but [required] is a keyword in Dart.
  final bool? isRequired;

  final bool? deprecated;

  final String? style;

  final bool? explode;

  final bool? allowReserved;

  final Schema? schema;

  final Map<String, MediaType>? content;

  const Header({
    required this.isRequired,
    required this.deprecated,
    required this.style,
    required this.explode,
    required this.allowReserved,
    required this.schema,
    required this.content,
  });

  factory Header.fromMap(Map<String, dynamic> map) => Header(
        isRequired: map['required'],
        deprecated: map['deprecated'],
        style: map['style'],
        explode: map['explode'],
        allowReserved: map['allowReserved'],
        schema: map['schema'] == null ? null : Schema.fromMap(map['schema']),
        content: (map['content'] as Map<String, dynamic>?)?.mapValues(
          (e) => MediaType.fromMap(e),
        ),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Header &&
          runtimeType == other.runtimeType &&
          isRequired == other.isRequired &&
          deprecated == other.deprecated &&
          style == other.style &&
          explode == other.explode &&
          allowReserved == other.allowReserved &&
          schema == other.schema &&
          mapEquals(content, other.content);

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      isRequired.hashCode ^
      deprecated.hashCode ^
      style.hashCode ^
      explode.hashCode ^
      allowReserved.hashCode ^
      schema.hashCode ^
      mapHash(content);
}
