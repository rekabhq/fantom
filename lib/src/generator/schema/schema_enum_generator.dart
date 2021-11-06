import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/schema/schema_value_generator.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:meta/meta.dart';
import 'package:recase/recase.dart';

/// example:
///
/// abstract class A {
///   A._();
///
///   static final String x = 'x';
///   static final String y = 'y';
///   static final String z = 'z';
/// }
///
/// static final int num_0 = 0;
/// static final double num_1_5 = 1.5;
/// static final num num_1 = 1;
/// static final num num_1_5 = 1.5;
///
/// static final User item0 = ...;
class SchemaEnumGenerator {
  const SchemaEnumGenerator();

  GeneratedSchemaComponent generate(
    final DataElement element, {
    required final String name,
  }) {
    return GeneratedSchemaComponent(
      dataElement: element,
      fileContent: generateContent(element, name),
      fileName: _fileName(name),
    );
  }

  @visibleForTesting
  String generateContent(final DataElement element, final String name) {
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
    final names = _names(element, values);
    return [
      'abstract class $name {',
      '$name._();',
      for (var index = 0; index < values.length; index++)
        [
          'static final $type ',
          names[index],
          ' = ',
          svg.generate(element, value: values[index]),
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

  String _fileName(final String name) {
    return '${ReCase(name).snakeCase}.dart';
  }

  List<String> _names(
    final DataElement element,
    final List<Object?> values,
  ) {
    Iterable<String> it() sync* {
      for (var index = 0; index < values.length; index++) {
        yield _name(element, index, values[index]);
      }
    }

    return it().toList();
  }

  String _name(
    final DataElement element,
    final int index,
    final Object? value,
  ) {
    if (value == null && element.isNotNullable) {
      throw AssertionError('non-nullable element with null value in enum');
    }

    return element.match(
      boolean: (boolean) {
        if (value == null) {
          return 'value${index}_null';
        } else {
          if (value is! bool) {
            throw AssertionError('bad type for enum value');
          }

          if (value) {
            return 'value${index}_true';
          } else {
            return 'value${index}_false';
          }
        }
      },
      object: (object) {
        if (value is! Map<String, dynamic>?) {
          throw AssertionError('bad type for enum value');
        }

        return 'value$index';
      },
      array: (array) {
        if (value is! List<dynamic>?) {
          throw AssertionError('bad type for enum value');
        }

        return 'value$index';
      },
      integer: (integer) {
        if (value == null) {
          return 'value${index}_null';
        } else {
          if (value is! int) {
            throw AssertionError('bad type for enum value');
          }

          return 'value${index}_' + _int(value);
        }
      },
      number: (number) {
        if (number.isFloat) {
          if (value == null) {
            return 'value${index}_null';
          } else {
            if (value is! double) {
              throw AssertionError('bad type for enum value');
            }

            return 'value${index}_' + _double(value);
          }
        } else {
          if (value == null) {
            return 'value${index}_null';
          } else {
            if (value is! num) {
              throw AssertionError('bad type for enum value');
            }

            if (value is int) {
              return 'value${index}_' + _int(value);
            } else if (value is double) {
              return 'value${index}_' + _double(value);
            } else {
              throw AssertionError();
            }
          }
        }
      },
      string: (string) {
        final format = string.format;
        if (format == StringDataElementFormat.binary) {
          throw UnimplementedError('only plain string is supported');
        }

        if (value == null) {
          return 'value${index}_null';
        } else {
          if (value is! String) {
            throw AssertionError('bad type for enum value');
          }

          return 'value${index}_$value';
        }
      },
      untyped: (untyped) {
        throw UnimplementedError('untyped data element');
      },
    );
  }

  String _int(int value) {
    return '$value'.replaceAll('-', 'N');
  }

  String _double(double value) {
    return '$value'.replaceAll('-', 'N').replaceAll('.', '_');
  }
}
