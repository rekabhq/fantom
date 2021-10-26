import 'package:fantom/src/mediator/mediator/schema/schema_resolution.dart';
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
          return DataElement.nulling(
            name: name,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema),
            enumeration: _extractEnumerationInfo(schema),
          );
        case 'boolean':
          return DataElement.boolean(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema),
            enumeration: _extractEnumerationInfo(schema),
          );
        case 'object': // map and object
          // todo: simplify additionalItems calculation
          final DataElement? additionalItems;
          if (schema.properties == null) {
            // recursive call:
            additionalItems = _convert(
              openApi,
              // schema with only type of objects is
              // like schema with additionalProperties of an empty schema.
              schema.additionalProperties ?? Schema.empty(),
            );
          } else {
            additionalItems = schema.additionalProperties == null
                ? null
                // recursive call:
                : _convert(
                    openApi,
                    schema.additionalProperties!,
                  );
          }
          final requiredItems = (schema.requiredItems ?? []).toSet();
          return DataElement.object(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema),
            enumeration: _extractEnumerationInfo(schema),
            properties: schema.properties!.entries
                .map((entry) => ObjectProperty(
                      name: entry.key,
                      // recursive call:
                      item: _convert(openApi, entry.value),
                      isRequired: requiredItems.contains(entry.key),
                    ))
                .toList(),
            additionalItems: additionalItems,
          );
        case 'array':
          if (schema.items == null) throw UnimplementedError('untyped array');
          return DataElement.array(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema),
            enumeration: _extractEnumerationInfo(schema),
            // recursive call:
            items: _convert(openApi, schema.items!),
            isUniqueItems: schema.uniqueItems == true,
          );
        case 'integer':
          return DataElement.integer(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema),
            enumeration: _extractEnumerationInfo(schema),
          );
        case 'number':
          return DataElement.number(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema),
            enumeration: _extractEnumerationInfo(schema),
            isFloat: schema.format != null,
          );
        case 'string':
          return DataElement.string(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema),
            enumeration: _extractEnumerationInfo(schema),
          );
        case 'dynamic':
          return DataElement.untyped(
            name: name,
            isDeprecated: _extractIsDeprecated(schema),
            defaultValue: _extractDefaultValue(schema),
            enumeration: _extractEnumerationInfo(schema),
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

  DefaultValue? _extractDefaultValue(Schema schema) {
    return schema.defaultValue == null
        ? null
        : DefaultValue(
            value: schema.defaultValue!.value,
          );
  }

  EnumerationInfo? _extractEnumerationInfo(Schema schema) {
    return schema.enumerated == null
        ? null
        : EnumerationInfo(
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
