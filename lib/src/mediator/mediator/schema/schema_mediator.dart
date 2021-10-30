import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';

class SchemaMediator {
  // TODO: compatibility should be removed since we are not supporting openapi 3.1
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
      final referenceName = schema.reference!.name;
      if (!schemas.containsKey(referenceName)) {
        throw AssertionError('bad reference "$referenceName"');
      }
      final referencedSchema = schemas[referenceName]!;
      if ((schema.nullable == null) &&
          (schema.type == null) &&
          (schema.format == null) &&
          (schema.defaultValue == null) &&
          (schema.deprecated == null) &&
          (schema.requiredItems == null) &&
          (schema.enumerated == null) &&
          (schema.items == null) &&
          (schema.properties == null) &&
          (schema.uniqueItems == null) &&
          (schema.additionalProperties == null)) {
        // not mixing reference and schema:
        return _convert(schemas, referencedSchema, referenceName);
      } else {
        // mixing reference and schema:
        final overriddenSchema = Schema(
          nullable: (schema.nullable == null)
              ? referencedSchema.nullable
              : schema.nullable,
          reference: referencedSchema.reference,
          type: (schema.type == null) ? referencedSchema.type : schema.type,
          format:
              (schema.format == null) ? referencedSchema.format : schema.format,
          defaultValue: (schema.defaultValue == null)
              ? referencedSchema.defaultValue
              : schema.defaultValue,
          deprecated: (schema.deprecated == null)
              ? referencedSchema.deprecated
              : schema.deprecated,
          requiredItems: (schema.requiredItems == null)
              ? referencedSchema.requiredItems
              : schema.requiredItems,
          enumerated: (schema.enumerated == null)
              ? referencedSchema.enumerated
              : schema.enumerated,
          items: (schema.items == null) ? referencedSchema.items : schema.items,
          properties: (schema.properties == null)
              ? referencedSchema.properties
              : schema.properties,
          uniqueItems: (schema.uniqueItems == null)
              ? referencedSchema.uniqueItems
              : schema.uniqueItems,
          additionalProperties: (schema.additionalProperties == null)
              ? referencedSchema.additionalProperties
              : schema.additionalProperties,
        );
        return _convert(schemas, overriddenSchema);
      }
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
          if (schema.properties == null) {
            // recursive call:
            final items = _convert(
              schemas,
              // schema with only type of objects is
              // like schema with additionalProperties of an empty schema.
              schema.additionalProperties ?? Schema.empty(),
            );
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
            final requiredItems = (schema.requiredItems ?? []).toSet();
            final dartType = name?.nullify(isNullable);
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
              additionalItems: schema.additionalProperties == null
                  ? null
                  // recursive call:
                  : _convert(schemas, schema.additionalProperties!),
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
        case 'dynamic':
          if (isNullable != true) throw AssertionError();
          final dartType = 'dynamic';
          return DataElement.untyped(
            type: dartType,
            name: name,
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
    if (type == null) {
      return _FullType(
        type: 'dynamic',
        isNullable: true,
      );
    } else {
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
        final set = type.wrap().toSet();
        if (set.isEmpty) {
          return _FullType(
            type: 'dynamic',
            isNullable: true,
          );
        } else if (set.length == 1 ||
            (set.length == 2 && set.contains('null'))) {
          return _FullType(
            type: set.length == 1
                ? set.first
                : (Set.of(set)..remove('null')).first,
            isNullable: set.contains('null'),
          );
        } else {
          throw UnimplementedError('multi-type schema');
        }
      }
    }
  }

  bool _extractIsDeprecated(Schema schema) => schema.deprecated == true;

  DefaultValue? _extractDefaultValue(
    Schema schema,
    String? dartType,
  ) =>
      schema.defaultValue == null
          ? null
          : DefaultValue(
              type: dartType,
              value: schema.defaultValue!.value,
            );

  EnumerationInfo? _extractEnumerationInfo(
    Schema schema,
    String? dartType,
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
  String get name => ref.removeFromStart('#/components/schemas/');
}

extension _StringTypeNullablityExt on String {
  /// nullify or not
  String nullify(bool isNullable) => isNullable ? this : '$this?';
}
