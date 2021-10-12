part of 'model.dart';

class Schema {
  final String? type;

  final String? format;

  final String? pattern;

  final Object? defaultValue;

  final bool? nullable;

  final bool? depreciated;

  final List<String>? required;

  /// described as [enum] in documentation.
  /// but [enum], is a keyword in Dart.
  final List? enumerated;

  final Schema? items;

  final Map<String, Schema>? properties;

  const Schema({
    required this.type,
    required this.format,
    required this.pattern,
    required this.defaultValue,
    required this.nullable,
    required this.depreciated,
    required this.required,
    required this.enumerated,
    required this.items,
    required this.properties,
  });
}
