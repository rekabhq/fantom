import 'package:fantom/src/generator/schema/schema_enum_generator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:test/test.dart';

void main() {
  group('SchemaEnumGenerator', () {
    late SchemaEnumGenerator seg;

    setUp(() {
      seg = SchemaEnumGenerator();
    });

    group('generate', () {
      group('boolean', () {
        test('non-nullable', () {
          final x = seg.generateContent(
            DataElement.boolean(
              enumeration: Enumeration(values: [
                true,
                false,
              ]),
            ),
            'MyEnum',
          );
          expect(
            x,
            r'''abstract class MyEnum {
MyEnum._();
static final bool value0_true = true;
static final bool value1_false = false;
static final List<bool> values = [value0_true, value1_false,];
}''',
          );
        });

        test('nullable', () {
          final x = seg.generateContent(
            DataElement.boolean(
              isNullable: true,
              enumeration: Enumeration(values: [
                null,
                false,
              ]),
            ),
            'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final bool? value0_null = null;
static final bool? value1_false = false;
static final List<bool?> values = [value0_null, value1_false,];
}''',
          );
        });
      });

      group('object', () {
        test('non-nullable', () {
          final x = seg.generateContent(
            DataElement.object(
              name: 'User',
              properties: [
                ObjectProperty(
                  name: 'id',
                  item: DataElement.integer(),
                  isRequired: true,
                ),
              ],
              enumeration: Enumeration(values: [
                {
                  'id': 100,
                },
                {
                  'id': 200,
                },
              ]),
            ),
            'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final User value0 = User.fromJson(<String, dynamic>{'id': 100});
static final User value1 = User.fromJson(<String, dynamic>{'id': 200});
static final List<User> values = [value0, value1,];
}''',
          );
        });

        test('nullable', () {
          final x = seg.generateContent(
            DataElement.object(
              name: 'User',
              isNullable: true,
              properties: [
                ObjectProperty(
                  name: 'id',
                  item: DataElement.integer(),
                  isRequired: true,
                ),
              ],
              enumeration: Enumeration(values: [
                null,
                {
                  'id': 200,
                },
              ]),
            ),
            'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final User? value0_null = null;
static final User? value1 = User.fromJson(<String, dynamic>{'id': 200});
static final List<User?> values = [value0_null, value1,];
}''',
          );
        });
      });

      group('array', () {
        test('non-nullable', () {
          final x = seg.generateContent(
            DataElement.array(
              items: DataElement.integer(),
              enumeration: Enumeration(values: [
                [1, 2],
                [3, 4, 5],
              ]),
            ),
            'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final List<int> value0 = <int>[1, 2];
static final List<int> value1 = <int>[3, 4, 5];
static final List<List<int>> values = [value0, value1,];
}''',
          );
        });

        test('nullable', () {
          final x = seg.generateContent(
            DataElement.array(
              isNullable: true,
              isUniqueItems: true,
              items: DataElement.integer(),
              enumeration: Enumeration(values: [
                null,
                [3, 4, 5],
              ]),
            ),
            'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final Set<int>? value0_null = null;
static final Set<int>? value1 = <int>{3, 4, 5};
static final List<Set<int>?> values = [value0_null, value1,];
}''',
          );
        });
      });

      group('integer', () {
        test('non-nullable', () {
          final x = seg.generateContent(
            DataElement.integer(
              enumeration: Enumeration(values: [
                10,
                20,
              ]),
            ),
            'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final int value0_10 = 10;
static final int value1_20 = 20;
static final List<int> values = [value0_10, value1_20,];
}''',
          );
        });

        test('nullable', () {
          final x = seg.generateContent(
            DataElement.integer(
              isNullable: true,
              enumeration: Enumeration(values: [
                null,
                20,
              ]),
            ),
            'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final int? value0_null = null;
static final int? value1_20 = 20;
static final List<int?> values = [value0_null, value1_20,];
}''',
          );
        });
      });

      group('number', () {
        test('non-nullable', () {
          final x = seg.generateContent(
            DataElement.number(
              isFloat: true,
              enumeration: Enumeration(values: [
                10.12,
                20.56,
              ]),
            ),
            'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final double value0_10_12 = 10.12;
static final double value1_20_56 = 20.56;
static final List<double> values = [value0_10_12, value1_20_56,];
}''',
          );
        });

        test('nullable', () {
          final x = seg.generateContent(
            DataElement.number(
              isFloat: false,
              isNullable: true,
              enumeration: Enumeration(values: [
                null,
                20,
                13.506,
              ]),
            ),
            'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final num? value0_null = null;
static final num? value1_20 = 20;
static final num? value2_13_506 = 13.506;
static final List<num?> values = [value0_null, value1_20, value2_13_506,];
}''',
          );
        });
      });

      group('string', () {
        test('non-nullable', () {
          final x = seg.generateContent(
            DataElement.string(
              enumeration: Enumeration(values: [
                'abc',
                'def',
              ]),
            ),
            'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final String value0_abc = 'abc';
static final String value1_def = 'def';
static final List<String> values = [value0_abc, value1_def,];
}''',
          );
        });

        test('nullable', () {
          final x = seg.generateContent(
            DataElement.string(
              isNullable: true,
              enumeration: Enumeration(values: [
                null,
                'def',
              ]),
            ),
            'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final String? value0_null = null;
static final String? value1_def = 'def';
static final List<String?> values = [value0_null, value1_def,];
}''',
          );
        });
      });
    });
  });
}
