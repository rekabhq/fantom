import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';

class SchemaMediator {
  final bool compatibility;

  const SchemaMediator({
    required this.compatibility,
  });

  DataElement convert({
    required final Map<String, Schema>? schemas,
    required final Schema schema,
    final String? name,
  }) =>
      _convert(schemas ?? const {}, schema, name);

  DataElement _convert(
    final Map<String, Schema> schemas,
    final Schema schema, [
    final String? name,
  ]) {
    if (schema.reference != null) {
      if (name != null) {
        throw UnimplementedError('mixing name and reference is not supported');
      }

      // todo: support making nullable
      if (schema.nullable != null ||
          schema.type != null ||
          schema.format != null ||
          schema.defaultValue != null ||
          schema.deprecated != null ||
          schema.requiredItems != null ||
          schema.enumerated != null ||
          schema.items != null ||
          schema.properties != null ||
          schema.uniqueItems != null ||
          schema.additionalProperties != null) {
        throw UnimplementedError(
          'mixing reference and other properties '
          'of schema is not supported',
        );
      }

      final referenceName = schema.reference!.name;
      if (!schemas.containsKey(referenceName)) {
        throw AssertionError('bad reference "$referenceName"');
      }
      return _convert(schemas, schemas[referenceName]!, referenceName);
    } else {
      final fullType = _extractFullType(schema);
      final type = fullType.type;
      final isNullable = fullType.isNullable;
      switch (type) {
        case 'null':
          if (isNullable != true) throw AssertionError();
          final dartType = 'Null';
          return DataElement.nulling(
            type: dartType,
            name: name,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema, dartType),
            enumeration: _extractEnumerationInfo(schema, dartType, name),
          );
        case 'boolean':
          final dartType = 'bool'.nullify(isNullable);
          return DataElement.boolean(
            type: dartType,
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema, dartType),
            enumeration: _extractEnumerationInfo(schema, dartType, name),
          );
        case 'object': // map and object
          if ((schema.properties != null && schema.properties!.isNotEmpty) &&
              (schema.additionalProperties != null)) {
            throw UnimplementedError('mixed object-map is not supported');
          }
          if (schema.additionalProperties != null) {
            // recursive call:
            final items = _convert(schemas, schema.additionalProperties!);
            final dartType = 'Map<String, ${items.type}>'.nullify(isNullable);
            return DataElement.map(
              type: dartType,
              name: name,
              isNullable: isNullable,
              isDeprecated: _extractIsDeprecated(schema),
              defaultValue: _extractDefaultValue(schema, dartType),
              enumeration: _extractEnumerationInfo(schema, dartType, name),
              items: items,
            );
          } else {
            if (name == null) {
              throw UnsupportedError('unnamed object');
            }
            final requiredItems = (schema.requiredItems ?? []).toSet();
            final dartType = name.nullify(isNullable);
            return DataElement.object(
              type: dartType,
              name: name,
              isNullable: isNullable,
              isDeprecated: _extractIsDeprecated(schema),
              defaultValue: _extractDefaultValue(schema, dartType),
              enumeration: _extractEnumerationInfo(schema, dartType, name),
              properties: schema.properties!.entries
                  .map((entry) => ObjectProperty(
                        name: entry.key,
                        // recursive call:
                        item: _convert(schemas, entry.value),
                        isRequired: requiredItems.contains(entry.key),
                      ))
                  .toList(),
            );
          }
        case 'array':
          if (schema.items == null) throw UnimplementedError('untyped array');
          // recursive call:
          final items = _convert(schemas, schema.items!);
          final isUniqueItems = schema.uniqueItems == true;
          final dartTypeBase = isUniqueItems ? 'Set' : 'List';
          final dartType = '$dartTypeBase<${items.type}>'.nullify(isNullable);
          return DataElement.array(
            type: dartType,
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema, dartType),
            enumeration: _extractEnumerationInfo(schema, dartType, name),
            items: items,
            isUniqueItems: schema.uniqueItems == true,
          );
        case 'integer':
          final dartType = 'int'.nullify(isNullable);
          return DataElement.number(
            type: dartType,
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema, dartType),
            enumeration: _extractEnumerationInfo(schema, dartType, name),
            isFloat: false,
          );
        case 'number':
          final isFloat = schema.format == null ? null : true;
          final dartTypeBase = isFloat == null ? 'num' : 'double';
          final dartType = dartTypeBase.nullify(isNullable);
          return DataElement.number(
            type: dartType,
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema, dartType),
            enumeration: _extractEnumerationInfo(schema, dartType, name),
            isFloat: isFloat,
          );
        case 'string':
          final dartType = 'String'.nullify(isNullable);
          return DataElement.string(
            type: dartType,
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema, dartType),
            enumeration: _extractEnumerationInfo(schema, dartType, name),
          );
        default:
          throw AssertionError('unknown type "$type"');
      }
    }
  }

  _FullType _extractFullType(Schema schema) {
    final type = schema.type;
    final nullable = schema.nullable;
    if (type == null) throw UnimplementedError('type-less schema');
    if (compatibility) {
      if (type.isList) throw AssertionError();
      final single = type.single;
      if (single == 'null') throw AssertionError();
      return _FullType(
        type: single,
        isNullable: nullable == true,
      );
    } else {
      if (nullable != null) throw AssertionError();
      final set = type.list.toSet();
      if (set.isEmpty) {
        throw UnimplementedError('type-less schema');
      } else if (set.length == 1 || (set.length == 2 && set.contains('null'))) {
        return _FullType(
          type:
              set.length == 1 ? set.first : (Set.of(set)..remove('null')).first,
          isNullable: set.contains('null'),
        );
      } else {
        throw UnimplementedError('multi-type schema');
      }
    }
  }

  bool _extractIsDeprecated(Schema schema) => schema.deprecated == true;

  DefaultValue? _extractDefaultValue(
    Schema schema,
    String dartType,
  ) =>
      schema.defaultValue == null
          ? null
          : DefaultValue(
              type: dartType,
              value: schema.defaultValue!.value,
            );

  EnumerationInfo? _extractEnumerationInfo(
    Schema schema,
    String dartType,
    String? schemaName,
  ) =>
      schema.enumerated == null
          ? null
          : EnumerationInfo(
              name: schemaName == null ? null : '${schemaName}Enum',
              type: dartType,
              values: schema.enumerated!,
            );
}

class _FullType {
  final String type;
  final bool isNullable;

  const _FullType({
    required this.type,
    required this.isNullable,
  });
}

extension _SchemaReferenceExt on Reference<Schema> {
  /// get schema name for a schema reference
  String get name => ref.removeFromStart('#components/schemas/');
}

/// Some nullability utilities
extension _StringTypeNullablityExt on String {
  String nullify(bool isNullable) => isNullable ? this : '$this?';
}
