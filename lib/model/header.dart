part of 'model.dart';

class Header {
  final bool? required;

  final bool? deprecated;

  final String? style;

  final bool? explode;

  final bool? allowReserved;

  final Schema? schema;

  final Map<String, MediaType>? content;

  const Header({
    required this.required,
    required this.deprecated,
    required this.style,
    required this.explode,
    required this.allowReserved,
    required this.schema,
    required this.content,
  });

  factory Header.fromMap(Map<String, dynamic> map) {
    // TODO: implement method
    throw UnimplementedError();
  }
}
