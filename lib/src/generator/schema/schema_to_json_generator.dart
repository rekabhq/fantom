import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';

class SchemaToJsonGenerator {
  const SchemaToJsonGenerator();

  String generateApplication(final DataElement element) {
    final type = element.type;
    if (type == null) {
      throw UnimplementedError('bad type for element');
    }

    return [
      '(($type value) => ',
      _logic(element, 'value'),
      ')',
    ].joinParts();
  }

  String generateForClass(final ObjectDataElement object) {
    final name = object.name;
    if (name == null) {
      throw UnimplementedError('anonymous objects are not supported');
    }
    if (object.format != ObjectDataElementFormat.object) {
      throw UnimplementedError(
        '"mixed" and "map" objects are not supported : name is ${object.name}',
      );
    }
    for (final property in object.properties) {
      if (property.item.type == null) {
        throw UnimplementedError('anonymous inner objects are not supported');
      }
    }

    return [
      'Map<String, dynamic> toJson() => ',
      _inner(object),
      ';',
    ].joinParts();
  }

  // safe for empty objects
  String _inner(final ObjectDataElement object) {
    return [
      '<String, dynamic>{',
      for (final property in object.properties)
        [
          _property(property),
          ',',
        ].joinParts(),
      '}',
    ].joinLines();
  }

  String _property(final ObjectProperty property) {
    final name = property.name;
    final isOptional = property.isFieldOptional;
    final fixedName = isOptional ? '$name!.value' : name;
    return [
      if (isOptional) 'if ($name != null) ',
      "'$name' : ",
      _logic(property.item, fixedName),
    ].joinParts();
  }

  String _logic(DataElement element, String name) {
    final isNullable = element.isNullable;
    final fixedName = isNullable ? '$name!' : name;
    return [
      if (isNullable) '$name == null ? null : ',
      element.match(
        boolean: (boolean) {
          return fixedName;
        },
        object: (object) {
          if (object.format == ObjectDataElementFormat.map) {
            final typeNN = object.typeNN;
            if (typeNN == null) {
              throw UnimplementedError('bad typed "map" object');
            }

            return [
              '(($typeNN value) => ',
              'value.map((key, it) => MapEntry(key, ',
              _logic(object.additionalProperties!, 'it'),
              '))',
              ')($fixedName)',
            ].joinParts();
          } else {
            return '$fixedName.toJson()';
          }
        },
        array: (array) {
          // list and set are equivalent here ...
          final typeNN = array.typeNN;
          if (typeNN == null) {
            throw UnimplementedError('bad typed array');
          }

          return [
            '(($typeNN value) => ',
            'value.map((it) => ',
            _logic(array.items, 'it'),
            ').toList()',
            ')($fixedName)',
          ].joinParts();
        },
        integer: (integer) {
          return fixedName;
        },
        number: (number) {
          return fixedName;
        },
        string: (string) {
          final format = string.format;
          if (format == StringDataElementFormat.binary) {
            throw UnimplementedError('only plain string is supported');
          }

          return fixedName;
        },
        untyped: (untyped) {
          throw UnimplementedError(
            'default values for untyped elements are not supported.',
          );
        },
      ),
    ].joinParts();
  }
}
