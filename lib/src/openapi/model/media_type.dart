part of 'model.dart';

class MediaType {
  final Schema? schema;

  final Map<String, Encoding>? encoding;

  const MediaType({
    required this.schema,
    required this.encoding,
  });

  factory MediaType.fromMap(Map<String, dynamic> map) => MediaType(
        schema: map['schema'] == null ? null : Schema.fromMap(map['schema']),
        encoding: (map['encoding'] as Map<String, dynamic>?)?.mapValues(
          (e) => Encoding.fromMap(e),
        ),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaType &&
          runtimeType == other.runtimeType &&
          schema == other.schema &&
          mapEquals(encoding, other.encoding);

  @override
  int get hashCode =>
      runtimeType.hashCode ^ schema.hashCode ^ mapHash(encoding);
}
