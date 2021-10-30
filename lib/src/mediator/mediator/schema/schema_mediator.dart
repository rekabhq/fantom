import 'package:fantom/src/mediator/mediator/schema/schema_resolution.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';

class SchemaMediator {
  // TODO: compatibility should be removed since we are not supporting openapi 3.1
  static const bool compatibility = true;

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
          final ObjectAdditionalProperties? additionalProperties;
          final schemaAdditionalProperties = schemaValue.additionalProperties;
          if (schemaAdditionalProperties == null) {
            additionalProperties = ObjectAdditionalProperties(
              items: null,
            );
          } else if (schemaAdditionalProperties.isBoolean) {
            if (schemaAdditionalProperties.boolean) {
              additionalProperties = ObjectAdditionalProperties(
                items: null,
              );
            } else {
              additionalProperties = null;
            }
          } else {
            additionalProperties = ObjectAdditionalProperties(
              // recursive call:
              items: _convert(
                openApi,
                schemaAdditionalProperties.value,
              ),
            );
          }
          final requiredItems = (schemaValue.requiredItems ?? const []).toSet();
          return DataElement.object(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
            properties: schemaValue.properties?.entries
                .map((entry) => ObjectProperty(
                      name: entry.key,
                      // recursive call:
                      item: _convert(openApi, entry.value),
                      isRequired: requiredItems.contains(entry.key),
                    ))
                .toList(),
            additionalProperties: additionalProperties,
          );
        case 'array':
          if (schemaValue.items == null) {
            throw UnimplementedError('untyped array');
          }
          return DataElement.array(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
            // recursive call:
            items: _convert(openApi, schemaValue.items!),
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
