part of 'model.dart';

class Encoding {
  final String? contentType;

  final Map<String, Header>? headers;

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
}
