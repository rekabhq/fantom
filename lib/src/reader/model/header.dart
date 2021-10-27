part of 'model.dart';

class Header extends Equatable {
  /// described as [required] in openapi documentation
  /// but [required] is a keyword in Dart.
  final bool? isRequired;

  final bool? deprecated;

  /// this parameter is going to deprecate in
  /// the following versions of the Open Api Spec
  final bool? allowEmptyValue;

  final String? style;

  final bool? explode;

  final bool? allowReserved;

  final Referenceable<Schema>? schema;

  final Map<String, MediaType>? content;

  const Header({
    required this.isRequired,
    required this.deprecated,
    required this.allowEmptyValue,
    required this.style,
    required this.explode,
    required this.allowReserved,
    required this.schema,
    required this.content,
  });

  factory Header.fromMap(Map<String, dynamic> map) => Header(
        isRequired: map['required'],
        deprecated: map['deprecated'],
        allowEmptyValue: map[' allowEmptyValue'],
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
        allowEmptyValue,
        style,
        explode,
        allowReserved,
        schema,
        content,
      ];
}
