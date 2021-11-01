import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';

class SchemaClassToJsonGenerator {
  const SchemaClassToJsonGenerator();

  String generate(final ObjectDataElement object) {
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
            // todo
            return "'map'";
          } else {
            return '$fixedName.toJson()';
          }
        },
        array: (array) {
          // list and set are equivalent here ...
          final typeNN = element.typeNN;
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
