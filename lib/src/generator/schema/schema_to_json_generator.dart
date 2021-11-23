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
    if (object.format == ObjectDataElementFormat.map) {
      throw AssertionError(
        'map objects are not supported : name is ${object.name}',
      );
    }

    return [
      'Map<String, dynamic> toJson() => ',
      _inner(object, inline, false),
      ';',
    ].joinParts();
  }

  // safe for empty objects
  String _inner(
    final ObjectDataElement object,
    final bool inline,
    final bool prefixCall,
  ) {
    // todo: uie
    if (object.format == ObjectDataElementFormat.mixed) {
      throw UnimplementedError('mixed objects is not supported');
    }

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
    final bool prefixCall,
  ) {
    final name = property.name;
    final nameCall = [
      if (prefixCall) 'value.',
      name,
    ].joinParts();
    return [
      "'$name' : ",
      _logic(property.item, nameCall, inline),
    ].joinParts();
  }

  String _logic(
    final DataElement element,
    final String name,
    final bool inline,
  ) {
    if (element.isEnumerated) {
      // ex. status.serialize()
      return '$name.serialize()';
    } else {
      final isNullable = element.isNullable;
      final fixedName = isNullable ? '$name!' : name;
      final code = element.match(
        boolean: (boolean) {
          return fixedName;
        },
        object: (object) {
          if (object.format == ObjectDataElementFormat.map) {
            final typeNN = object.rawTypeNN;
            return [
              '(($typeNN value) => ',
              'value.map((key, it) => MapEntry(key, ',
              _logic(object.additionalProperties!, 'it', inline),
              '))',
              ')($fixedName)',
            ].joinParts();
          } else {
            if (inline) {
              final typeNN = object.rawTypeNN;
              return [
                '(($typeNN value) => ',
                _inner(object, inline, true),
                ')($fixedName)',
              ].joinParts();
            } else {
              return '$fixedName.toJson()';
            }
          }
        },
        array: (array) {
          // list and set are equivalent here ...
          final typeNN = array.rawTypeNN;
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
          switch (string.format) {
            case StringDataElementFormat.plain:
              return fixedName;
            case StringDataElementFormat.byte:
              return fixedName;
            case StringDataElementFormat.binary:
              return fixedName;
            case StringDataElementFormat.date:
              return '$fixedName.toIso8601String()';
            case StringDataElementFormat.dateTime:
              return '$fixedName.toIso8601String()';
          }
        },
        untyped: (untyped) {
          return fixedName;
        },
      );

      return [
        if (isNullable) '$name == null ? null : ',
        code,
      ].joinParts();
    }
  }
}
