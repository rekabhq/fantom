part of 'model.dart';

class MediaType {
  final Schema? schema;

  final Map<String, Encoding>? encoding;

  const MediaType({
    required this.schema,
    required this.encoding,
  });

  // TODO - unit tests are required
  factory MediaType.fromMap(Map<String, dynamic> map) => MediaType(
        schema: map['schema'] == null ? null : Schema.fromMap(map['schema']),
        encoding: (map['encoding'] as Map<String, dynamic>?)?.mapValues(
          (e) => Encoding.fromMap(e),
        ),
      );
}
