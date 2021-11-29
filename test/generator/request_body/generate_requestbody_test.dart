import 'dart:io';

import 'package:fantom/src/generator/components/component_generator.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/request_body/requestbody_class_generator.dart';
import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/generator/schema/schema_enum_generator.dart';
import 'package:fantom/src/generator/schema/schema_from_json_generator.dart';
import 'package:fantom/src/generator/schema/schema_to_json_generator.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/mediator/schema/schema_mediator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  group('RequestBodyClassGenerator: ', () {
    late RequestBodyClassGenerator requestBodyClassGenerator;
    late OpenApi openapi;
    setUpAll(() async {
      print('');
      var openapiMap = await readJsonOrYamlFile(File('openapi_files/petstore.openapi.json'));
      openapi = OpenApi.fromMap(openapiMap);
      final componentsGenerator = ComponentsGenerator.createDefault(openapi);

      var map = componentsGenerator.generateSchemas(openapi.components!.schemas!);
      map.forEach((ref, component) {
        registerGeneratedComponent(ref, component);
      });
      requestBodyClassGenerator = componentsGenerator.requestBodyClassGenerator;
    });

    test(
      'test request_body type generation from map of mediaTypes => contents',
      () async {
        var requestBody = openapi.components!.requestBodies!.values.first.value;

        var output = requestBodyClassGenerator.generate(requestBody, 'Pet');

        var outputFile = File('test/generator/request_body/output.dart');

        var content = '''
import 'package:equatable/equatable.dart';

''';

        content += output.fileContent;

        // todo : fix ...

        content += SchemaEnumGenerator()
            .generateRecursively(
              SchemaMediator().convert(
                openApi: openapi,
                schema: requestBody.content.values.first.schema!,
                name: 'PetBodyApplicationJson',
              ),
            )
            .all
            .map((e) => e.fileContent)
            .join('\n\n');

        for (final key in openapi.components!.schemas!.keys) {
          if (key.startsWith('Obj') ||
              {
                'Category',
                'Tag',
                'User',
              }.contains(key)) {
            final schema = openapi.components!.schemas![key]!;
            final element = SchemaMediator().convert(
              openApi: openapi,
              schema: schema,
              name: key,
            );
            if (element is ObjectDataElement && element.format != ObjectDataElementFormat.map) {
              final component = SchemaClassGenerator().generate(element);
              content += component.fileContent;
            }
          }
        }

        content += r'''

// todo: uie, sets ?
bool fantomEquals(
  final Object? value1,
  final Object? value2,
) {
  return FantomEqualityModel(value1) == FantomEqualityModel(value2);
}

class FantomEqualityModel extends Equatable {
  final Object? value;

  const FantomEqualityModel(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'FantomEqualityModel($value)';
}

I fantomEnumSerialize<V extends Object, I extends Object>({
  required final List<V> values,
  required final List<I> items,
  required final V value,
}) {
  final length = items.length;
  for (var index = 0; index < length; index++) {
    if (values[index] == value) {
      return items[index];
    }
  }
  throw AssertionError('enum serialization: not found value.');
}

V fantomEnumDeserialize<V extends Object, I extends Object>({
  required final List<V> values,
  required final List<I> items,
  required final I item,
}) {
  final length = items.length;
  for (var index = 0; index < length; index++) {
    if (fantomEquals(items[index], item)) {
      return values[index];
    }
  }
  throw AssertionError('enum deserialization: not found item.');
}

// ignore_for_file: unnecessary_non_null_assertion, unnecessary_const, unused_local_variable

''';

        final a = ObjectDataElement(
          name: 'Sugar',
          isNullable: true,
          properties: [
            ObjectProperty(
              name: 'id',
              item: IntegerDataElement(
                isNullable: false,
                name: 'SugarId',
                defaultValue: DefaultValue(value: 50),
              ),
            ),
            ObjectProperty(
              name: 'amount',
              item: NumberDataElement(
                name: 'SugarAmount',
                isFloat: true,
                isNullable: true,
              ),
            ),
          ],
          defaultValue: DefaultValue(
            value: <String, dynamic>{
              'id': 1000,
              'amount': 10.5,
            },
          ),
        );
        content += SchemaClassGenerator().generateCode(
          a,
          generateJson: true,
        );
        final b = ObjectDataElement(
          name: 'Lollipop',
          isNullable: true,
          defaultValue: DefaultValue(value: {
            'count': 10000,
            'sugar': {
              'id': 156,
              'amount': 10.5,
            }
          }),
          properties: [
            ObjectProperty(
              name: 'id',
              item: IntegerDataElement(
                name: 'LollipopId',
                defaultValue: DefaultValue(value: 100),
                isNullable: true,
              ),
            ),
            ObjectProperty(
              name: 'count',
              item: IntegerDataElement(
                name: 'LollipopCount',
                isNullable: false,
              ),
            ),
            ObjectProperty(
              name: 'sugar',
              item: a,
            ),
          ],
        );
        content += SchemaClassGenerator().generateCode(
          b,
          generateJson: true,
          inlineJson: true,
          additionalCode: [
            [
              'static final toJsonApplication = ',
              SchemaToJsonGenerator().generateApplication(b),
              ';',
            ].joinParts(),
            SchemaToJsonGenerator().generateMethod(
              b,
              name: 'toJsonMethod',
              isStatic: true,
            ),
            [
              'static final fromJsonApplication = ',
              SchemaFromJsonGenerator().generateApplication(b),
              ';',
            ].joinParts(),
            SchemaFromJsonGenerator().generateMethod(
              b,
              name: 'fromJsonMethod',
              isStatic: true,
            ),
            [
              'static final toJsonApplicationInline = ',
              SchemaToJsonGenerator().generateApplication(
                b,
                inline: true,
              ),
              ';',
            ].joinParts(),
            SchemaToJsonGenerator().generateMethod(
              b,
              name: 'toJsonMethodInline',
              isStatic: true,
              inline: true,
            ),
            [
              'static final fromJsonApplicationInline = ',
              SchemaFromJsonGenerator().generateApplication(
                b,
                inline: true,
              ),
              ';',
            ].joinParts(),
            SchemaFromJsonGenerator().generateMethod(
              b,
              name: 'fromJsonMethodInline',
              isStatic: true,
              inline: true,
            ),
          ].joinMethods(),
        );
        final c = ObjectDataElement(
          name: 'Ginger',
          properties: [
            ObjectProperty(
              name: 'lollipop',
              item: b,
            ),
          ],
        );
        content += '\n\n';
        content += SchemaClassGenerator().generateCode(c);

        await outputFile.writeAsString(content);
      },
    );
  });
}
