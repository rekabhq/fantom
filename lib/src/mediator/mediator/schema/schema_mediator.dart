import 'package:fantom/src/mediator/mediator/schema/schema_resolution.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';

class SchemaMediator {
  const SchemaMediator();

  DataElement convert({
    /// this is used to resolve references
    required final OpenApi openApi,

    /// schema object as referenceable.
    /// if it is a value wrap it using `Referenceable.value()`.
    required final Referenceable<Schema> schema,

    /// this will be schemas map key,
    /// or a generated name according to context.
    required final String name,
  }) =>
      _convert(openApi, schema, name);

  DataElement _convert(
    final OpenApi openApi,
    final Referenceable<Schema> schema,
    final String name,
  ) {
    if (schema.isReference) {
      var schemaReference = schema.reference;
      final resolution = openApi.resolveSchema(schemaReference);
      // we are completely ignoring reference original data,
      // such as it's name ...
      return _convert(openApi, resolution.schema, resolution.name);
    } else {
      final schemaValue = schema.value;
      final type = schemaValue.type;
      final isNullable = schemaValue.nullable == true;
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
              : _convert(
                  openApi,
                  as,
                  // concatenate `$Items` to the end
                  '$name\$',
                );

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
                      item: _convert(
                        openApi,
                        entry.value,
                        // concatenate (`$` + `property name`) to the end
                        '$name\$${entry.key}',
                      ),
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
          final items = _convert(
            openApi,
            schemaValue.items!,
            // concatenate `$` to the end
            '$name\$',
          );

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
          final f = schemaValue.format?.toLowerCase();
          final StringDataElementFormat format;
          switch (f) {
            case 'byte':
              format = StringDataElementFormat.byte;
              break;
            case 'binary':
              format = StringDataElementFormat.binary;
              break;
            case 'date':
              format = StringDataElementFormat.date;
              break;
            case 'datetime':
              format = StringDataElementFormat.dateTime;
              break;
            default:
              format = StringDataElementFormat.plain;
              break;
          }

          return DataElement.string(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
            format: format,
          );
        case null:
          return DataElement.untyped(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
          );
        default:
          throw AssertionError('unknown type "$type"');
      }
    }
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

  Enumeration? _extractEnumerationInfo(Schema schemaValue) {
    return schemaValue.enumerated == null
        ? null
        : Enumeration(
            values: schemaValue.enumerated!,
          );
  }
}
