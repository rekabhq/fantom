part of 'model.dart';

class Parameter {
  final String name;

  /// described as [in] in documentation.
  /// but [in], is a keyword in Dart.
  final String location;

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

  final Schema? schema;

  final Map<String, MediaType>? content;

  const Parameter({
    required this.name,
    required this.location,
    required this.isRequired,
    required this.deprecated,
    required this.allowEmptyValue,
    required this.allowReserved,
    required this.style,
    required this.explode,
    required this.schema,
    required this.content,
  });

  factory Parameter.fromMap(Map<String, dynamic> map) => Parameter(
        name: map['name'],
        location: map['in'],
        isRequired: map['required'],
        deprecated: map['deprecated'],
        style: map['style'],
        explode: map['explode'],
        allowReserved: map['allowReserved'],
        schema: map['schema'] == null ? null : Schema.fromMap(map['schema']),
        content: (map['content'] as Map<String, dynamic>?)?.mapValues(
          (e) => MediaType.fromMap(e),
        ),
        allowEmptyValue: map['allowEmptyValue'],
      );
}
