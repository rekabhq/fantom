part of 'model.dart';

class Parameter {
  final String name;

  /// described as [in] in documentation.
  /// but in, is a keyword in Dart.
  final String location;

  final bool? required;

  final bool? deprecated;

  /// this parameter is going to depreciate in
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
    required this.required,
    required this.deprecated,
    required this.allowEmptyValue,
    required this.allowReserved,
    required this.style,
    required this.explode,
    required this.schema,
    required this.content,
  });
}
