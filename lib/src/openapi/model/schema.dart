part of 'model.dart';

class Schema {
  final String? type;

  final String? format;

  final String? pattern;

  /// described as [default] in openapi documentation
  /// but [default] is a keyword in Dart.
  final Object? defaultValue;

  final bool? nullable;

  final bool? deprecated;

  /// described as [required] in openapi documentation
  /// but [required] is a keyword in Dart.
  final List<String>? requiredItems;

  /// described as [enum] in documentation.
  /// but [enum], is a keyword in Dart.
  final List<Object?>? enumerated;

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

  // TODO - unit tests are required
  factory Schema.fromMap(Map<String, dynamic> map) => Schema(
      type: map['type'],
      format: map['format'],
      pattern: map['pattern'],
      defaultValue: map['default'],
      nullable: map['nullable'],
      deprecated: map['deprecated'],
      requiredItems: (map['required'] as List<dynamic>?)?.cast<String>(),
      enumerated: (map['enum'] as List<dynamic>?)?.cast<Object?>(),
      items: map['items'] == null
          ? null
          : Referenceable.fromMap(
              map['items'],
              builder: (m) => Schema.fromMap(m),
            ),
      properties: (map['properties'] as Map<String, dynamic>?)?.mapValues(
        (e) => Referenceable.fromMap(
          e,
          builder: (m) => Schema.fromMap(m),
        ),
      ),
    );
}
