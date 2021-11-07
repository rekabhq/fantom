import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';

class SchemaToJsonGenerator {
  const SchemaToJsonGenerator();

  /// ex. ((User value) => value.toJson())
  String generateApplication(
    final DataElement element, {
    final bool inline = false,
  }) {
    final type = element.type;
    if (type == null) {
      throw UnimplementedError('bad type for element');
    }

    return [
      '(($type value) => ',
      _logic(element, 'value', inline),
      ')',
    ].joinParts();
  }

  /// ex. static dynamic toJson(User value) => value.toJson();
  String generateMethod(
    final DataElement element, {
    final String name = 'toJson',
    final bool isStatic = true,
    final bool inline = false,
  }) {
    final type = element.type;
    if (type == null) {
      throw UnimplementedError('bad type for element');
    }

    return [
      if (isStatic) 'static ',
      'dynamic $name($type value) => ',
      _logic(element, 'value', inline),
      ';',
    ].joinParts();
  }

  /// ex. Map<String, dynamic> toJson() => ...;
  String generateForClass(
    final ObjectDataElement object, {
    final bool inline = false,
  }) {
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
      _inner(object, inline, null),
      ';',
    ].joinParts();
  }

  // safe for empty objects
  String _inner(
    final ObjectDataElement object,
    final bool inline,
    final String? prefixCall,
  ) {
    return [
      '<String, dynamic>{',
      for (final property in object.properties)
        [
          _property(property, inline, prefixCall),
          ',',
        ].joinParts(),
      '}',
    ].joinLines();
  }

  String _property(
    final ObjectProperty property,
    final bool inline,
    final String? prefixCall,
  ) {
    final name = property.name;
    final nameCall = [
      if (prefixCall != null) '$prefixCall.',
      name,
    ].joinParts();
    final isOptional = property.isFieldOptional;
    final fixedName = isOptional ? '$nameCall!.value' : nameCall;
    return [
      if (isOptional) 'if ($nameCall != null) ',
      "'$name' : ",
      _logic(property.item, fixedName, inline),
    ].joinParts();
  }

  String _logic(
    final DataElement element,
    final String name,
    final bool inline,
  ) {
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
              _logic(object.additionalProperties!, 'it', inline),
              '))',
              ')($fixedName)',
            ].joinParts();
          } else {
            if (inline) {
              final typeNN = object.typeNN;
              if (typeNN == null) {
                throw UnimplementedError('object with no name');
              }

              return [
                '(($typeNN value) => ',
                _inner(object, inline, 'value'),
                ')($fixedName)',
              ].joinParts();
            } else {
              return '$fixedName.toJson()';
            }
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
            _logic(array.items, 'it', inline),
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
