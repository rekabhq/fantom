import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/openapi/model/model.dart';
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
          return DataElement.nulling(
            name: name,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema),
            enumeration: _extractEnumerationInfo(schema, name),
          );
        case 'boolean':
          return DataElement.boolean(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema),
            enumeration: _extractEnumerationInfo(schema, name),
          );
        case 'object': // map and object
          if ((schema.properties != null && schema.properties!.isNotEmpty) &&
              (schema.additionalProperties != null)) {
            throw UnimplementedError('mixed object-map is not supported');
          }
          if (schema.additionalProperties != null) {
            return DataElement.map(
              name: name,
              isNullable: isNullable,
              isDeprecated: _extractIsDeprecated(schema),
              defaultValue: _extractDefaultValue(schema),
              enumeration: _extractEnumerationInfo(schema, name),
              // recursive call
              items: _convert(schemas, schema.additionalProperties!),
            );
          } else {
            final requiredItems = (schema.requiredItems ?? []).toSet();
            return DataElement.object(
              name: name,
              isNullable: isNullable,
              isDeprecated: _extractIsDeprecated(schema),
              defaultValue: _extractDefaultValue(schema),
              enumeration: _extractEnumerationInfo(schema, name),
              properties: schema.properties!.entries
                  .map((entry) => ObjectProperty(
                        name: entry.key,
                        // recursive call
                        item: _convert(schemas, entry.value),
                        isRequired: requiredItems.contains(entry.key),
                      ))
                  .toList(),
            );
          }
        case 'array':
          if (schema.items == null) throw UnimplementedError('untyped array');
          return DataElement.array(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema),
            enumeration: _extractEnumerationInfo(schema, name),
            // recursive call
            items: _convert(schemas, schema.items!),
            isUniqueItems: schema.uniqueItems == true,
          );
        case 'integer':
          return DataElement.number(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema),
            enumeration: _extractEnumerationInfo(schema, name),
            isFloat: false,
          );
        case 'number':
          return DataElement.number(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema),
            enumeration: _extractEnumerationInfo(schema, name),
            isFloat: schema.format == null ? null : true,
          );
        case 'string':
          return DataElement.string(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema),
            enumeration: _extractEnumerationInfo(schema, name),
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

  DefaultValue? _extractDefaultValue(Schema schema) =>
      schema.defaultValue == null
          ? null
          : DefaultValue(schema.defaultValue!.value);

  EnumerationInfo? _extractEnumerationInfo(Schema schema, String? schemaName) =>
      schema.enumerated == null
          ? null
          : EnumerationInfo(
              name: schemaName == null ? null : '${schemaName}Enum',
              type: 'Null',
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
