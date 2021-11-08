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
          final x = seg.generateEnum(
            DataElement.boolean(
              name: 'myName',
              enumeration: Enumeration(values: [
                true,
                false,
              ]),
            ),
            name: 'MyEnum',
          );
          expect(
            x,
            r'''abstract class MyEnum {
MyEnum._();
static final bool value0 = true;
static final bool value1 = false;
static final bool value_true = value0;
static final bool value_false = value1;
static final List<bool> values = [value0, value1,];
}''',
          );
        });

        test('nullable', () {
          final x = seg.generateEnum(
            DataElement.boolean(
              isNullable: true,
              name: 'myName',
              enumeration: Enumeration(values: [
                null,
                false,
              ]),
            ),
            name: 'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final bool? value0 = null;
static final bool? value1 = false;
static final bool? valueNull = value0;
static final bool? value_false = value1;
static final List<bool?> values = [value0, value1,];
}''',
          );
        });
      });

      group('object', () {
        test('non-nullable', () {
          final x = seg.generateEnum(
            DataElement.object(
              name: 'User',
              properties: [
                ObjectProperty(
                  name: 'id',
                  item: DataElement.integer(
                    name: 'UserId',
                  ),
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
            name: 'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final User value0 = User(id : 100,);
static final User value1 = User(id : 200,);
static final List<User> values = [value0, value1,];
}''',
          );
        });

        test('nullable', () {
          final x = seg.generateEnum(
            DataElement.object(
              name: 'User',
              isNullable: true,
              properties: [
                ObjectProperty(
                  name: 'id',
                  item: DataElement.integer(
                    name: 'UserId',
                  ),
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
            name: 'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final User? value0 = null;
static final User? value1 = User(id : 200,);
static final User? valueNull = value0;
static final List<User?> values = [value0, value1,];
}''',
          );
        });
      });

      group('array', () {
        test('non-nullable', () {
          final x = seg.generateEnum(
            DataElement.array(
              items: DataElement.integer(
                name: 'myNameItems',
              ),
              name: 'myName',
              enumeration: Enumeration(values: [
                [1, 2],
                [3, 4, 5],
              ]),
            ),
            name: 'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final List<int> value0 = <int>[1, 2,];
static final List<int> value1 = <int>[3, 4, 5,];
static final List<List<int>> values = [value0, value1,];
}''',
          );
        });

        test('nullable', () {
          final x = seg.generateEnum(
            DataElement.array(
              isNullable: true,
              isUniqueItems: true,
              items: DataElement.integer(
                name: 'myNameItems',
              ),
              name: 'myName',
              enumeration: Enumeration(values: [
                null,
                [3, 4, 5],
              ]),
            ),
            name: 'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final Set<int>? value0 = null;
static final Set<int>? value1 = <int>{3, 4, 5,};
static final Set<int>? valueNull = value0;
static final List<Set<int>?> values = [value0, value1,];
}''',
          );
        });
      });

      group('integer', () {
        test('non-nullable', () {
          final x = seg.generateEnum(
            DataElement.integer(
              name: 'myName',
              enumeration: Enumeration(values: [
                10,
                20,
              ]),
            ),
            name: 'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final int value0 = 10;
static final int value1 = 20;
static final int value_10 = value0;
static final int value_20 = value1;
static final List<int> values = [value0, value1,];
}''',
          );
        });

        test('nullable', () {
          final x = seg.generateEnum(
            DataElement.integer(
              isNullable: true,
              name: 'myName',
              enumeration: Enumeration(values: [
                null,
                20,
              ]),
            ),
            name: 'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final int? value0 = null;
static final int? value1 = 20;
static final int? valueNull = value0;
static final int? value_20 = value1;
static final List<int?> values = [value0, value1,];
}''',
          );
        });
      });

      group('number', () {
        test('non-nullable', () {
          final x = seg.generateEnum(
            DataElement.number(
              isFloat: true,
              name: 'myName',
              enumeration: Enumeration(values: [
                10.12,
                20.56,
              ]),
            ),
            name: 'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final double value0 = 10.12;
static final double value1 = 20.56;
static final double value_10_12 = value0;
static final double value_20_56 = value1;
static final List<double> values = [value0, value1,];
}''',
          );
        });

        test('nullable', () {
          final x = seg.generateEnum(
            DataElement.number(
              isFloat: false,
              isNullable: true,
              name: 'myName',
              enumeration: Enumeration(values: [
                null,
                20,
                13.506,
              ]),
            ),
            name: 'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final num? value0 = null;
static final num? value1 = 20;
static final num? value2 = 13.506;
static final num? valueNull = value0;
static final num? value_20 = value1;
static final num? value_13_506 = value2;
static final List<num?> values = [value0, value1, value2,];
}''',
          );
        });
      });

      group('string', () {
        test('non-nullable', () {
          final x = seg.generateEnum(
            DataElement.string(
              name: 'myName',
              enumeration: Enumeration(values: [
                'abc',
                'def',
              ]),
            ),
            name: 'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final String value0 = 'abc';
static final String value1 = 'def';
static final String value_abc = value0;
static final String value_def = value1;
static final List<String> values = [value0, value1,];
}''',
          );
        });

        test('nullable', () {
          final x = seg.generateEnum(
            DataElement.string(
              isNullable: true,
              name: 'myName',
              enumeration: Enumeration(values: [
                null,
                'def',
              ]),
            ),
            name: 'MyEnum',
          );
          expect(
            x,
            r'''
abstract class MyEnum {
MyEnum._();
static final String? value0 = null;
static final String? value1 = 'def';
static final String? valueNull = value0;
static final String? value_def = value1;
static final List<String?> values = [value0, value1,];
}''',
          );
        });
      });
    });
  });
}
