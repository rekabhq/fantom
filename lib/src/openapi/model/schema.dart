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
  final List<String>? enumerated;

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
  factory Schema.fromMap(Map<String, dynamic> map) {
    final requiredItems = map['required'] == null
        ? <String>[]
        : (map['required'] as List).map((item) => item.toString()).toList();
    final enumerated = map['enum'] == null
        ? null
        : (map['enum'] as List).map((item) => item.toString()).toList();

    final items = map['items'] == null
        ? null
        : (!map['items'].contains('\$ref'))
            ? Referenceable<Schema>.value(Schema.fromMap(map['items']))
            : Referenceable<Schema>.reference(Reference.fromMap(map['items']));

    final properties = map['properties'] == null
        ? null
        : (map['responses'] as Map<String, dynamic>)
            .map<String, Referenceable<Schema>>(
            (key, value) => MapEntry(
              key,
              !value.contain('\$ref')
                  ? Referenceable.value(Schema.fromMap(value))
                  : Referenceable.reference(Reference.fromMap(value)),
            ),
          );

    return Schema(
      type: map['type'],
      format: map['format'],
      pattern: map['pattern'],
      defaultValue: map['default'],
      nullable: map['nullable'],
      deprecated: map['deprecated'],
      requiredItems: requiredItems,
      enumerated: enumerated,
      items: items,
      properties: properties,
    );
  }
}
