import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';

class SchemaFromJsonGenerator {
  const SchemaFromJsonGenerator();

  /// ex. ((dynamic json) => User.fromJson(json))
  String generateApplication(final DataElement element) {
    return [
      '((dynamic json) => ',
      _logic(element, 'json'),
      ')',
    ].joinParts();
  }

  /// ex. User fromJson(dynamic json) => User.fromJson(json);
  String generateMethod(
    final DataElement element, {
    final String name = 'fromJson',
    final bool isStatic = true,
  }) {
    final type = element.type;
    if (type == null) {
      throw UnimplementedError('bad type for element');
    }

    return [
      if (isStatic) 'static ',
      '$type $name(dynamic json) => ',
      _logic(element, 'json'),
      ';',
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
      'factory $name.fromJson(Map<String, dynamic> json) => ',
      _inner(object),
      ';',
    ].joinParts();
  }

  String _inner(final ObjectDataElement object) {
    final name = object.name!;

    return [
      '$name(',
      for (final property in object.properties)
        [
          _property(property),
          ',',
        ].joinParts(),
      ')'
    ].joinLines();
  }

  String _property(final ObjectProperty property) {
    final name = property.name;
    final isOptional = property.isConstructorOptional;
    final fixedName = "json['$name']";
    return [
      '$name: ',
      if (isOptional) "json.containsKey('$name') ? Optional(",
      _logic(property.item, fixedName),
      if (isOptional) ') : null'
    ].joinParts();
  }

  String _logic(DataElement element, String name) {
    final isNullable = element.isNullable;
    final fixedName = isNullable ? '$name!' : name;

    final String code = element.match(
      boolean: (boolean) {
        return fixedName;
      },
      object: (object) {
        if (object.format == ObjectDataElementFormat.map) {
          final sub = object.additionalProperties!.type;
          if (sub == null) {
            throw UnimplementedError('bad typed map');
          }

          return [
            '((Map<String, dynamic> json) => ',
            'json.map<String, $sub>((key, it) => ',
            'MapEntry(key, ',
            _logic(object.additionalProperties!, 'it'),
            '))',
            ')($fixedName)',
          ].joinParts();
        } else {
          final className = object.name;
          if (className == null) {
            throw UnimplementedError(
              'anonymous inner objects are not supported',
            );
          }

          return '$className.fromJson($fixedName)';
        }
      },
      array: (array) {
        final sub = array.items.type;
        if (sub == null) {
          throw UnimplementedError('bad typed array');
        }

        return [
          '((List<dynamic> json) => ',
          'json.map<$sub>((it) => ',
          _logic(array.items, 'it'),
          ')',
          array.isUniqueItems ? '.toSet()' : '.toList()',
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
    );

    return [
      if (isNullable) '$name == null ? null : ',
      code,
    ].joinParts();
  }
}
