import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/generator/schema/schema_enum_generator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:test/test.dart';

void _check(String code) {
  // print(code);
  expect(code, isNotEmpty);
}

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
              name: 'MyName1',
              enumeration: Enumeration(values: [
                true,
                false,
              ]),
            ),
          );
          _check(x);
        });

        test('nullable', () {
          final x = seg.generateEnum(
            DataElement.boolean(
              isNullable: true,
              name: 'MyName2',
              enumeration: Enumeration(values: [
                null,
                false,
              ]),
            ),
          );
          _check(x);
        });
      });

      group('object', () {
        test('non-nullable', () {
          final element = DataElement.object(
            name: 'User1',
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
          );
          final x = seg.generateEnum(element);
          _check(
            SchemaClassGenerator().generateClass(
              element as ObjectDataElement,
            ),
          );
          _check(x);
        });

        test('nullable', () {
          final element = DataElement.object(
            name: 'User2',
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
          );
          final x = seg.generateEnum(element);
          _check(
            SchemaClassGenerator().generateClass(
              element as ObjectDataElement,
            ),
          );
          _check(x);
        });
      });

      group('array', () {
        test('non-nullable', () {
          final x = seg.generateEnum(
            DataElement.array(
              items: DataElement.integer(
                name: 'MyNameItems',
              ),
              name: 'MyName3',
              enumeration: Enumeration(values: [
                [1, 2],
                [3, 4, 5],
              ]),
            ),
          );
          _check(x);
        });

        test('nullable', () {
          final x = seg.generateEnum(
            DataElement.array(
              isNullable: true,
              isUniqueItems: true,
              items: DataElement.integer(
                name: 'MyNameItems',
              ),
              name: 'MyName4',
              enumeration: Enumeration(values: [
                null,
                [3, 4, 5],
              ]),
            ),
          );
          _check(x);
        });
      });

      group('integer', () {
        test('non-nullable', () {
          final x = seg.generateEnum(
            DataElement.integer(
              name: 'MyName5',
              enumeration: Enumeration(values: [
                10,
                20,
              ]),
            ),
          );
          _check(x);
        });

        test('nullable', () {
          final x = seg.generateEnum(
            DataElement.integer(
              isNullable: true,
              name: 'MyName6',
              enumeration: Enumeration(values: [
                null,
                20,
              ]),
            ),
          );
          _check(x);
        });
      });

      group('number', () {
        test('non-nullable', () {
          final x = seg.generateEnum(
            DataElement.number(
              isFloat: true,
              name: 'MyName7',
              enumeration: Enumeration(values: [
                10.12,
                20.56,
              ]),
            ),
          );
          _check(x);
        });

        test('nullable', () {
          final x = seg.generateEnum(
            DataElement.number(
              isFloat: false,
              isNullable: true,
              name: 'MyName8',
              enumeration: Enumeration(values: [
                null,
                20,
                13.506,
              ]),
            ),
          );
          _check(x);
        });
      });

      group('string', () {
        test('non-nullable', () {
          final x = seg.generateEnum(
            DataElement.string(
              name: 'MyName9',
              enumeration: Enumeration(values: [
                'abc',
                'def',
              ]),
            ),
          );
          _check(x);
        });

        test('nullable', () {
          final x = seg.generateEnum(
            DataElement.string(
              isNullable: true,
              name: 'MyName10',
              enumeration: Enumeration(values: [
                null,
                'def',
              ]),
            ),
          );
          _check(x);
        });
      });
    });
  });
}
