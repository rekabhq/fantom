part of 'model.dart';

class MediaType extends Equatable {
  final Referenceable<Schema>? schema;

  final Map<String, Encoding>? encoding;

  const MediaType({
    required this.schema,
    required this.encoding,
  });

  factory MediaType.fromMap(Map<String, dynamic> map) => MediaType(
        schema: map['schema'] == null
            ? null
            : Referenceable.fromMap(
                map['schema'],
                builder: (m) => Schema.fromMap(m),
              ),
        encoding: (map['encoding'] as Map<String, dynamic>?)?.mapValues(
          (e) => Encoding.fromMap(e),
        ),
      );

  @override
  List<Object?> get props => [
        schema,
        encoding,
      ];

  @override
  String toString() => 'MediaType{schema: $schema, encoding: $encoding}';
}
