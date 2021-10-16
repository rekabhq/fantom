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

  factory Header.fromMap(Map<String, dynamic> map) {
    // Mapping schema object
    final schema = map['schema'] == null ? null : Schema.fromMap(map['schema']);

    // Mapping content object
    final content = map['content'] == null
        ? null
        : (map['content'] as Map<String, dynamic>).map<String, MediaType>(
            (key, value) => MapEntry(key, MediaType.fromMap(value)),
          );

    return Header(
      isRequired: map['required'],
      deprecated: map['deprecated'],
      style: map['style'],
      explode: map['explode'],
      allowReserved: map['allowReserved'],
      schema: schema,
      content: content,
    );
  }
}
