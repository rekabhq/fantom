import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';

class SchemaFromJsonGenerator {
  const SchemaFromJsonGenerator();

  /// ex. ((dynamic json) => User.fromJson(json))
  String generateApplication(
    final DataElement element, {
    final bool inline = false,
  }) {
    return [
      '((dynamic json) => ',
      _logic(element, 'json', inline),
      ')',
    ].joinParts();
  }

  /// ex. User fromJson(dynamic json) => User.fromJson(json);
  String generateMethod(
    final DataElement element, {
    final String name = 'fromJson',
    final bool isStatic = true,
    final bool inline = false,
  }) {
    final type = element.type;
    if (type == null) {
      throw UnimplementedError('bad type for element');
    }

    return [
      if (isStatic) 'static ',
      '$type $name(dynamic json) => ',
      _logic(element, 'json', inline),
      ';',
    ].joinParts();
  }

  String generateForClass(
    final ObjectDataElement object, {
    final bool inline = false,
  }) {
    final name = object.name;
    if (object.format == ObjectDataElementFormat.map) {
      throw UnimplementedError(
        'map objects are not supported : name is ${object.name}',
      );
    }
    for (final property in object.properties) {
      if (property.item.type == null) {
        throw UnimplementedError('anonymous inner objects are not supported');
      }
    }

    return [
      'factory $name.fromJson(Map<String, dynamic> json) => ',
      _inner(object, inline),
      ';',
    ].joinParts();
  }

  // safe for empty objects
  String _inner(
    final ObjectDataElement object,
    final bool inline,
  ) {
    if (object.format == ObjectDataElementFormat.mixed) {
      throw UnimplementedError('mixed objects is not supported');
    }

    final name = object.name;
    return [
      '$name(',
      for (final property in object.properties)
        [
          _property(property, inline),
          ',',
        ].joinParts(),
      ')'
    ].joinLines();
  }

  String _property(
    final ObjectProperty property,
    final bool inline,
  ) {
    final name = property.name;
    final isOptional = property.isConstructorOptional;
    final fixedName = "json['$name']";
    return [
      '$name: ',
      if (isOptional) "json.containsKey('$name') ? Optional(",
      _logic(property.item, fixedName, inline),
      if (isOptional) ') : null'
    ].joinParts();
  }

  String _logic(
    final DataElement element,
    final String name,
    final bool inline,
  ) {
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
            _logic(object.additionalProperties!, 'it', inline),
            '))',
            ')($fixedName)',
          ].joinParts();
        } else {
          final typeNN = object.typeNN;
          if (typeNN == null) {
            throw UnimplementedError(
              'anonymous inner objects are not supported',
            );
          }

          if (inline) {
            return [
              '((Map<String, dynamic> json) => ',
              _inner(object, inline),
              ')($fixedName)',
            ].joinParts();
          } else {
            return '$typeNN.fromJson($fixedName)';
          }
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
          _logic(array.items, 'it', inline),
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
