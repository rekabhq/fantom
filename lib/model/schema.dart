part of 'model.dart';

class Schema {
  final String? type;

  final String? format;

  final String? pattern;

  final Object? defaultValue;

  final bool? nullable;

  final bool? deprecated;

  /// described as [required] in openapi documentation
  /// but [required] is a keyword in Dart.
  final List<String>? requiredItems;

  /// described as [enum] in documentation.
  /// but [enum], is a keyword in Dart.
  final List? enumerated;

  final Referenceable<Schema>? items;

  final Map<String, Referenceable<Schema>>? properties;

  const Schema({
    required this.type,
    required this.format,
    required this.pattern,
    required this.defaultValue,
    required this.nullable,
    required this.deprecated,
    required this.requiredItems,
    required this.enumerated,
    required this.items,
    required this.properties,
  });

  factory Schema.fromMap(Map<String, dynamic> map) {
    // TODO: implement method
    throw UnimplementedError();
  }
}
