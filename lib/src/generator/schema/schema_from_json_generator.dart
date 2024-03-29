import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';

String generateJsonDeserilzationBoilerplateFor({
  required DataElement element,
  required String jsonObjectName,
  required String deserializedObjectName,
}) {
  final generator = SchemaFromJsonGenerator();
  final application = generator.generateApplication(element);
  return '''
  final deserializer = $application;
  final $deserializedObjectName = deserializer($jsonObjectName);
  ''';
}

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
      throw AssertionError(
        'map objects are not supported : name is ${object.name}',
      );
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
    // todo: uie
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
    final fixedName = "json['$name']";
    return [
      '$name: ',
      _logic(property.item, fixedName, inline),
    ].joinParts();
  }

  String _logic(
    final DataElement element,
    final String name,
    final bool inline, {
    final bool ignoreTopEnum = false,
    final bool ignoreTopNullability = false,
  }) {
    final isNullable = !ignoreTopNullability && element.isNullable;
    final fixedName = isNullable ? '$name!' : name;

    final String code;
    if (!ignoreTopEnum && element.isEnumerated) {
      // ex. StatusExt.deserialize(_logic(value))
      code = [
        element.enumName,
        'Ext.deserialize(',
        _logic(
          element,
          fixedName,
          inline,
          ignoreTopEnum: true,
          ignoreTopNullability: true,
        ),
        ',)',
      ].joinParts();
    } else {
      code = element.match(
        boolean: (boolean) {
          return fixedName;
        },
        object: (object) {
          if (object.format == ObjectDataElementFormat.map) {
            final sub = object.additionalProperties!.type;
            return [
              '((Map<String, dynamic> json) => ',
              'json.map<String, $sub>((key, it) => ',
              'MapEntry(key, ',
              _logic(object.additionalProperties!, 'it', inline),
              '))',
              ')($fixedName)',
            ].joinParts();
          } else {
            if (inline) {
              return [
                '((Map<String, dynamic> json) => ',
                _inner(object, inline),
                ')($fixedName)',
              ].joinParts();
            } else {
              return [
                object.name,
                '.fromJson($fixedName)',
              ].joinParts();
            }
          }
        },
        array: (array) {
          final sub = array.items.type;
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
          switch (string.format) {
            case StringDataElementFormat.plain:
              return fixedName;
            case StringDataElementFormat.byte:
              return fixedName;
            case StringDataElementFormat.binary:
              return fixedName;
            case StringDataElementFormat.date:
              return 'DateTime.parse($fixedName)';
            case StringDataElementFormat.dateTime:
              return 'DateTime.parse($fixedName)';
          }
        },
        untyped: (untyped) {
          return fixedName;
        },
        ref: (ref) => ref.isNullable == true
            ? '$fixedName == null ? null : ${ref.name}.fromJson($fixedName)'
            : '${ref.name}.fromJson($fixedName)',
      );
    }

    return [
      if (isNullable) '$name == null ? null : ',
      code,
    ].joinParts();
  }
}
