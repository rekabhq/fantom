import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/schema/schema_value_generator.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:meta/meta.dart';
import 'package:recase/recase.dart';

extension SchemaEnumGeneratorExt on SchemaEnumGenerator {
  GeneratedSchemaComponent generate(
    final DataElement element, {
    required final String name,
    final bool noJson = true,
  }) {
    return GeneratedSchemaComponent(
      dataElement: element,
      fileContent: generateEnum(
        element,
        name: name,
        noJson: noJson,
      ),
      fileName: '${ReCase(name).snakeCase}.dart',
    );
  }
}

class SchemaEnumGenerator {
  const SchemaEnumGenerator();

  @visibleForTesting
  String generateEnum(
    final DataElement element, {
    required final String name,
    final bool noJson = true,
  }) {
    final enumeration = element.enumeration;
    if (enumeration == null) {
      throw AssertionError('element ${element.name} does not contain an enum');
    }
    final values = enumeration.values;
    if (values.isEmpty) {
      // can this happen ?
      throw AssertionError('element ${element.name} with empty enum');
    }
    final type = element.type;
    if (type == null) {
      throw UnimplementedError('bad typed element');
    }

    final svg = SchemaValueGenerator();
    final names = [
      for (var index = 0; index < values.length; index++) 'value$index',
    ];
    return [
      'abstract class $name {',
      '$name._();',
      for (var index = 0; index < values.length; index++)
        [
          'static final $type ',
          names[index],
          ' = ',
          svg.generate(
            element,
            value: values[index],
            noJson: noJson,
          ),
          ';',
        ].joinParts(),
      for (var index = 0; index < values.length; index++)
        if (_canSpecific(element, values[index]))
          [
            'static final $type ',
            values[index] == null
                ? 'valueNull'
                : [
                    'value_',
                    _specific(element, values[index]),
                  ].joinParts(),
            ' = ',
            names[index],
            ';',
          ].joinParts(),
      [
        'static final List<$type> values = [',
        names.joinArgsFull(),
        '];',
      ].joinParts(),
      '}',
    ].joinLines();
  }

  /// also check types ...
  bool _canSpecific(
    final DataElement element,
    final Object? value,
  ) {
    if (value == null) {
      return true;
    } else {
      return element.match(
        boolean: (boolean) => true,
        object: (object) => false,
        array: (array) => false,
        integer: (integer) => true,
        number: (number) => true,
        string: (string) => string.format != StringDataElementFormat.binary,
        untyped: (untyped) => false,
      );
    }
  }

  String _specific(
    final DataElement element,
    final Object? value,
  ) {
    if (value == null) {
      return 'null';
    } else {
      return element.match(
        boolean: (boolean) {
          if (value is! bool) {
            throw AssertionError('bad type for enum value');
          }
          if (value) {
            return 'true';
          } else {
            return 'false';
          }
        },
        object: (object) {
          throw AssertionError();
        },
        array: (array) {
          throw AssertionError();
        },
        integer: (integer) {
          if (value is! int) {
            throw AssertionError('bad type for enum value');
          }
          return _int(value);
        },
        number: (number) {
          if (number.isFloat) {
            if (value is! double) {
              throw AssertionError('bad type for enum value');
            }
            return _double(value);
          } else {
            if (value is! num) {
              throw AssertionError('bad type for enum value');
            }
            return _num(value);
          }
        },
        string: (string) {
          final format = string.format;
          if (format == StringDataElementFormat.binary) {
            throw UnimplementedError('only plain string is supported');
          }
          if (value is! String) {
            throw AssertionError('bad type for enum value');
          }
          return value;
        },
        untyped: (untyped) {
          throw UnimplementedError('untyped data element');
        },
      );
    }
  }

  String _int(int value) {
    return '$value'.replaceAll('-', 'N');
  }

  String _double(double value) {
    return '$value'.replaceAll('-', 'N').replaceAll('.', '_');
  }

  String _num(num value) {
    if (value is int) {
      return _int(value);
    } else if (value is double) {
      return _double(value);
    } else {
      throw AssertionError();
    }
  }
}
