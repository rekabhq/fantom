part of 'model.dart';

class Header extends Equatable {
  /// described as [required] in openapi documentation
  /// but [required] is a keyword in Dart.
  final bool? isRequired;

  final bool? deprecated;

  final String? style;

  final bool? explode;

  final bool? allowReserved;

  final Referenceable<Schema>? schema;

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
        schema: map['schema'] == null
            ? null
            : Referenceable.fromMap(
                map['schema'],
                builder: (m) => Schema.fromMap(m),
              ),
        content: (map['content'] as Map<String, dynamic>?)?.mapValues(
          (e) => MediaType.fromMap(e),
        ),
      );

  @override
  List<Object?> get props => [
        isRequired,
        deprecated,
        style,
        explode,
        allowReserved,
        schema,
        content,
      ];
}
