import 'package:fantom/src/mediator/mediator/schema/data_element_registry.dart';
import 'package:fantom/src/mediator/utils/schema/schema_resolution.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/logger.dart';

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

    /// reference address of this component in openapi components
    required final String schemaRef,
  }) =>
      _convert(openApi, schema, name, schemaRef);

  DataElement _convert(
    final OpenApi openApi,
    final ReferenceOr<Schema> schema,
    final String name,
    final String schemaRef, {
    final bool forceNullable = false,
  }) {
    if (dataElementRegistry.isRegistering(schemaRef)) {
      return DataElement.reference(ref: schemaRef);
    } else if (dataElementRegistry.isRegistered(schemaRef)) {
      return dataElementRegistry[schemaRef]!;
    }

    dataElementRegistry.setAsRegistering(schemaRef);

    if (schema.isReference) {
      var schemaReference = schema.reference;
      final resolution = openApi.resolveSchema(schemaReference);
      // we are completely ignoring reference original data,
      // such as it's name ...
      final dataElement = _convert(
        openApi,
        resolution.schema,
        resolution.name,
        schemaReference.ref,
        // cascade forceNullable down the line:
        forceNullable: forceNullable,
      );

      dataElementRegistry.register(schemaRef, dataElement);
      return dataElement;
    } else {
      final schemaValue = schema.value;
      final type = schemaValue.type;
      final isNullable = forceNullable || schemaValue.nullable == true;

      DataElement dataElement;

      switch (type) {
        case 'boolean':
          dataElement = DataElement.boolean(
            name: name,
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
                  '${name}AdditionalProperty',
                  '');

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
                          '$name${entry.key.toUpperStart()}',
                          entry.value.isReference
                              ? entry.value.reference.ref
                              : '',
                          forceNullable: !requiredItems.contains(entry.key),
                        );
                        dataElementRegistry.register(
                          entry.value.isReference
                              ? entry.value.reference.ref
                              : '',
                          dataElement,
                        );
                        return dataElement;
                      }(),
                    ),
                  )
                  .toList();

          dataElement = DataElement.object(
            name: name,
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
              '${name}Item',
              '');

          dataElement = DataElement.array(
            name: name,
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
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
          );
          break;
        case 'number':
          dataElement = DataElement.number(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
            isFloat: schemaValue.format != null,
          );
          break;
        case 'string':
          dataElement = DataElement.string(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
            format: _extractStringFormat(schemaValue),
          );
          break;
        case null:
          dataElement = DataElement.untyped(
            name: name,
            isNullable: isNullable,
            isDeprecated: _extractIsDeprecated(schemaValue),
            defaultValue: _extractDefaultValue(schemaValue),
            enumeration: _extractEnumerationInfo(schemaValue),
          );
          break;
        default:
          throw AssertionError('unknown type "$type"');
      }

      dataElementRegistry.register(schemaRef, dataElement);
      dataElement = dataElement.resolveReferences(schemaRef);
      dataElementRegistry.register(schemaRef, dataElement);

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

extension DataElementMediatorExt on DataElement {
  DataElement resolveReferences(String ref) {
    final de = this;
    if (de is ReferenceDataElement) {
      Log.debug('KKKK resolving ReferenceDataElement with ref=${de.ref}');
      final resolved = dataElementRegistry[de.ref];
      return resolved ?? this;
    } else if (de is ObjectDataElement) {
      final resolvedProperties = de.properties.map((property) {
        return ObjectProperty(
          name: property.name,
          item: property.item.resolveReferences(ref),
        );
      }).toList();

      return ObjectDataElement(
        name: de.name,
        properties: resolvedProperties,
        additionalProperties: de.additionalProperties?.resolveReferences(ref),
        defaultValue: de.defaultValue,
        enumeration: de.enumeration,
        isDeprecated: de.isDeprecated,
        isNullable: de.isNullable,
      );
    } else if (de is ArrayDataElement) {
      return ArrayDataElement(
        name: de.name,
        items: de.items.resolveReferences(ref),
        defaultValue: de.defaultValue,
        enumeration: de.enumeration,
        isDeprecated: de.isDeprecated,
        isNullable: de.isNullable,
        isUniqueItems: de.isUniqueItems,
      );
    }

    return this;
  }
}
