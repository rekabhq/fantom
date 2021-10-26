import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';

class SchemaMediator {
  final bool compatibility;

  const SchemaMediator({
    required this.compatibility,
  });

  DataElement convert({
    required final OpenApi openApi,
    required final Schema schema,
    final String? name,
  }) =>
      _convert(openApi, schema, name);

  DataElement _convert(
    final OpenApi openApi,
    final Schema schema, [
    final String? name,
  ]) {
    if (schema.reference != null) {
      final resolution = openApi.resolveSchema(schema.reference!);
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
        // todo: shouldn't we use referenced name ?
        return _convert(openApi, resolution.schema, name);
      } else {
        // mixing reference and schema:
        final overriddenSchema = Schema(
          nullable: (schema.nullable == null)
              ? resolution.schema.nullable
              : schema.nullable,
          reference: resolution.schema.reference,
          type: (schema.type == null) ? resolution.schema.type : schema.type,
          format: (schema.format == null)
              ? resolution.schema.format
              : schema.format,
          defaultValue: (schema.defaultValue == null)
              ? resolution.schema.defaultValue
              : schema.defaultValue,
          deprecated: (schema.deprecated == null)
              ? resolution.schema.deprecated
              : schema.deprecated,
          requiredItems: (schema.requiredItems == null)
              ? resolution.schema.requiredItems
              : schema.requiredItems,
          enumerated: (schema.enumerated == null)
              ? resolution.schema.enumerated
              : schema.enumerated,
          items:
              (schema.items == null) ? resolution.schema.items : schema.items,
          properties: (schema.properties == null)
              ? resolution.schema.properties
              : schema.properties,
          uniqueItems: (schema.uniqueItems == null)
              ? resolution.schema.uniqueItems
              : schema.uniqueItems,
          additionalProperties: (schema.additionalProperties == null)
              ? resolution.schema.additionalProperties
              : schema.additionalProperties,
        );
        return _convert(openApi, overriddenSchema, name);
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
              openApi,
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
                        item: _convert(openApi, entry.value),
                        isRequired: requiredItems.contains(entry.key),
                      ))
                  .toList(),
              additionalItems: schema.additionalProperties == null
                  ? null
                  // recursive call:
                  : _convert(openApi, schema.additionalProperties!),
            );
          }
        case 'array':
          if (schema.items == null) throw UnimplementedError('untyped array');
          // recursive call:
          final items = _convert(openApi, schema.items!);
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

  bool _extractIsDeprecated(Schema schema) {
    return schema.deprecated == true;
  }

  DefaultValue? _extractDefaultValue(
    Schema schema,
    String? dartType,
  ) {
    return schema.defaultValue == null
        ? null
        : DefaultValue(
            type: dartType,
            value: schema.defaultValue!.value,
          );
  }

  EnumerationInfo? _extractEnumerationInfo(
    Schema schema,
    String? dartType,
    String? schemaName,
  ) {
    return schema.enumerated == null
        ? null
        : EnumerationInfo(
            name: schemaName == null ? null : '${schemaName}Enum',
            type: dartType,
            values: schema.enumerated!,
          );
  }
}

class _FullType {
  final String type;
  final bool isNullable;

  const _FullType({
    required this.type,
    required this.isNullable,
  });
}

extension OpenApiSchemaResolutionExt on OpenApi {
  SchemaResolutionInfo resolveSchema(final Reference<Schema> reference) {
    if (reference.ref.startsWith('#/components/schemas/')) {
      final name = reference.ref.removeFromStart('#/components/schemas/');
      final schema = components?.schemas?[name];
      if (schema != null) {
        return SchemaResolutionInfo(
          name: name,
          schema: components!.schemas![name]!,
        );
      } else {
        throw AssertionError('bad reference "${reference.ref}"');
      }
    } else {
      throw UnimplementedError(
        'unsupported schema reference "${reference.ref}"',
      );
    }
  }
}

class SchemaResolutionInfo {
  final String name;
  final Schema schema;

  const SchemaResolutionInfo({
    required this.name,
    required this.schema,
  });
}
