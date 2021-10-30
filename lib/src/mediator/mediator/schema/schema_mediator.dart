import 'package:fantom/src/mediator/mediator/schema/schema_resolution.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';

class SchemaMediator {
  const SchemaMediator();

  DataElement convert({
    required final OpenApi openApi,
    required final Referenceable<Schema> schema,
    final String? name,
  }) =>
      _convert(openApi, schema, name);

  DataElement _convert(
    final OpenApi openApi,
    final Referenceable<Schema> schema, [
    final String? name,
  ]) {
    if (schema.isReference) {
      var schemaReference = schema.reference;
      final resolution = openApi.resolveSchema(schemaReference);
      // todo: shouldn't we use `name` ?
      return _convert(openApi, resolution.schema, resolution.name);
    } else {
      final schemaValue = schema.value;
      final fullType = _extractFullType(schemaValue);
      final type = fullType.type;
      final isNullable = fullType.isNullable;
      switch (type) {
        case 'boolean':
          return DataElement.boolean(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
          );
        case 'object': // map and object
          // calculation for additional properties:
          final aps = schemaValue.additionalProperties;
          final as = aps == null
              ? Referenceable.value(Schema.empty())
              : aps.isBoolean
                  ? aps.boolean
                      ? Referenceable.value(Schema.empty())
                      : null
                  : aps.value; // aps.isValue == true
          final additionalProperties = as == null
              ? null
              // recursive call:
              : _convert(openApi, as);

          // calculation for required items:
          final requiredItems = (schemaValue.requiredItems ?? []).toSet();

          // calculation for properties:
          final ps = schemaValue.properties;
          final properties = ps == null
              ? <ObjectProperty>[]
              : ps.entries
                  .map(
                    (entry) => ObjectProperty(
                      name: entry.key,
                      // recursive call:
                      item: _convert(openApi, entry.value),
                      isRequired: requiredItems.contains(entry.key),
                    ),
                  )
                  .toList();

          return DataElement.object(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
            properties: properties,
            additionalProperties: additionalProperties,
          );
        case 'array':
          // calculation for items:
          // recursive call:
          final items = _convert(openApi, schemaValue.items!);

          return DataElement.array(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
            items: items,
            isUniqueItems: schemaValue.uniqueItems == true,
          );
        case 'integer':
          return DataElement.integer(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
          );
        case 'number':
          return DataElement.number(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
            isFloat: schemaValue.format != null,
          );
        case 'string':
          return DataElement.string(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
            format: StringDataElementFormat.plain,
          );
        case 'dynamic':
          return DataElement.untyped(
            name: name,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
          );
        default:
          throw AssertionError('unknown type "$type"');
      }
    }
  }

  _FullType _extractFullType(Schema schemaValue) {
    final type = schemaValue.type;
    final nullable = schemaValue.nullable;
    return _FullType(
      type: type ?? 'dynamic',
      isNullable: nullable == true,
    );
  }

  bool _extractIsDeprecated(Schema schemaValue) {
    return schemaValue.deprecated == true;
  }

  DefaultValue? _extractDefaultValue(Schema schemaValue) {
    return schemaValue.defaultValue == null
        ? null
        : DefaultValue(
            value: schemaValue.defaultValue!.value,
          );
  }

  EnumerationInfo? _extractEnumerationInfo(Schema schemaValue) {
    return schemaValue.enumerated == null
        ? null
        : EnumerationInfo(
            values: schemaValue.enumerated!,
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
