import 'package:fantom/src/mediator/mediator/schema/data_element_registry.dart';
import 'package:fantom/src/mediator/utils/schema/schema_resolution.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';

class SchemaMediator {
  const SchemaMediator();

  DataElement convert({
    /// this is used to resolve references
    required final OpenApi openApi,

    /// schema object as [ReferenceOr].
    /// if it is a value wrap it using `ReferenceOr.value()`.
    required final ReferenceOr<Schema> schema,

    /// this will be schemas map key,
    /// or a generated name according to context.
    required final String name,
  }) =>
      _convert(openApi, schema, name);

  DataElement _convert(
    final OpenApi openApi,
    final ReferenceOr<Schema> schema,
    final String ref, {
    final bool forceNullable = false,
  }) {
    if (dataElementRegistry.isRegistered(ref)) {
      return dataElementRegistry[ref]!;
    }
    if (schema.isReference) {
      var schemaReference = schema.reference;
      final resolution = openApi.resolveSchema(schemaReference);
      // we are completely ignoring reference original data,
      // such as it's name ...
      final dataElement = _convert(
        openApi,
        resolution.schema,
        resolution.name,
        // cascade forceNullable down the line:
        forceNullable: forceNullable,
      );

      dataElementRegistry.register(ref, dataElement);
      return dataElement;
    } else {
      final schemaValue = schema.value;
      final type = schemaValue.type;
      final isNullable = forceNullable || schemaValue.nullable == true;

      DataElement dataElement;

      switch (type) {
        case 'boolean':
          dataElement = DataElement.boolean(
            name: ref,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
          );
          break;
        case 'object': // map and object
          // calculation for additional properties:
          final aps = schemaValue.additionalProperties;
          final as = aps == null
              ? ReferenceOr.value(Schema.empty())
              : aps.isBoolean
                  ? aps.boolean
                      ? ReferenceOr.value(Schema.empty())
                      : null
                  : aps.value; // aps.isValue == true
          final additionalProperties = as == null
              ? null
              // recursive call:
              : _convert(
                  openApi,
                  as,
                  // concatenate `AdditionalProperty` to the end
                  '${ref}AdditionalProperty',
                );
          if (additionalProperties != null) {
            dataElementRegistry.register(
              '${ref}AdditionalProperty',
              additionalProperties,
            );
          }

          // calculation for required items:
          final requiredItems = (schemaValue.requiredItems ?? []).toSet();

          // calculation for properties:
          // if property is required then we should not change nullability.
          // if is not required we should change to nullable forcefully.
          final ps = schemaValue.properties;
          final properties = ps == null
              ? <ObjectProperty>[]
              : ps.entries
                  .map(
                    (entry) => ObjectProperty(
                      name: entry.key,
                      // recursive call:
                      item: () {
                        final dataElement = _convert(
                          openApi,
                          entry.value,
                          // concatenate `property name`
                          // with upper start to the end
                          '$ref${entry.key.toUpperStart()}',
                          forceNullable: !requiredItems.contains(entry.key),
                        );
                        dataElementRegistry.register(
                          '$ref${entry.key.toUpperStart()}',
                          dataElement,
                        );
                        return dataElement;
                      }(),
                    ),
                  )
                  .toList();

          dataElement = DataElement.object(
            name: ref,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
            properties: properties,
            additionalProperties: additionalProperties,
          );
          break;
        case 'array':
          // calculation for items:
          // recursive call:
          final items = _convert(
            openApi,
            schemaValue.items!,
            // concatenate `Item` to the end
            '${ref}Item',
          );

          dataElementRegistry.register('${ref}Item', items);

          dataElement = DataElement.array(
            name: ref,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
            items: items,
            isUniqueItems: schemaValue.uniqueItems == true,
          );
          break;
        case 'integer':
          dataElement = DataElement.integer(
            name: ref,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
          );
          break;
        case 'number':
          dataElement = DataElement.number(
            name: ref,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
            isFloat: schemaValue.format != null,
          );
          break;
        case 'string':
          dataElement = DataElement.string(
            name: ref,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
            format: _extractStringFormat(schemaValue),
          );
          break;
        case null:
          dataElement = DataElement.untyped(
            name: ref,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
          );
          break;
        default:
          throw AssertionError('unknown type "$type"');
      }

      dataElementRegistry.register(ref, dataElement);
      return dataElement;
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
            // filter null elements:
            values: schemaValue.enumerated!.whereType<Object>().toList(),
          );
  }

  StringDataElementFormat _extractStringFormat(Schema schemaValue) {
    switch (schemaValue.format?.toLowerCase()) {
      case 'byte':
        return StringDataElementFormat.byte;
      case 'binary':
        return StringDataElementFormat.binary;
      case 'date':
        return StringDataElementFormat.date;
      case 'date-time':
        return StringDataElementFormat.dateTime;
      default:
        return StringDataElementFormat.plain;
    }
  }
}

extension StringCaseExt on String {
  String toUpperStart() {
    if (isEmpty) {
      return this;
    } else {
      final p1 = substring(0, 1);
      final p2 = substring(1);
      return p1.toUpperCase() + p2;
    }
  }
}
