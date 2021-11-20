import 'dart:io';

import 'package:fantom/src/generator/components/component_generator.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/request_body/requestbody_class_generator.dart';
import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/generator/schema/schema_enum_generator.dart';
import 'package:fantom/src/mediator/mediator/schema/schema_mediator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

// import 'package:fantom/src/generator/schema/schema_from_json_generator.dart';
// import 'package:fantom/src/generator/schema/schema_to_json_generator.dart';
// import 'package:fantom/src/generator/utils/string_utils.dart';

void main() {
  group('RequestBodyClassGenerator: ', () {
    late RequestBodyClassGenerator requestBodyClassGenerator;
    late OpenApi openapi;
    setUpAll(() async {
      print('');
      var openapiMap =
          await readJsonOrYamlFile(File('openapi_files/petstore.openapi.json'));
      openapi = OpenApi.fromMap(openapiMap);
      final componentsGenerator = ComponentsGenerator.createDefault(openapi);

      var map =
          componentsGenerator.generateSchemas(openapi.components!.schemas!);
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
            .generateEnumsRecursively(
              SchemaMediator().convert(
                openApi: openapi,
                schema: requestBody.content.values.first.schema!,
                name: 'PetBodyApplicationJson',
              ),
            )
            .map((e) => e.code)
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
            if (element is ObjectDataElement &&
                element.format != ObjectDataElementFormat.map) {
              final component = SchemaClassGenerator().generate(element);
              content += component.fileContent;
            }
          }
        }

        content += r'''

class Optional<T extends Object?> extends Equatable {
  final T value;

  const Optional(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Optional($value)';
}

bool _equals(
  final Object? value1,
  final Object? value2,
) {
  return _Equals(value1) == _Equals(value2);
}

class _Equals extends Equatable {
  final Object? value;

  const _Equals(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => '_Equals($value)';
}

// ignore_for_file: prefer_initializing_formals, prefer_null_aware_operators, prefer_if_null_operators, unnecessary_non_null_assertion

''';

        // final a = ObjectDataElement(
        //   name: 'Sugar',
        //   isNullable: true,
        //   properties: [
        //     ObjectProperty(
        //       name: 'id',
        //       item: IntegerDataElement(
        //         name: 'SugarId',
        //         defaultValue: DefaultValue(value: 50),
        //       ),
        //       isRequired: false,
        //     ),
        //     ObjectProperty(
        //       name: 'amount',
        //       item: NumberDataElement(
        //         name: 'SugarAmount',
        //         isFloat: true,
        //         isNullable: true,
        //       ),
        //       isRequired: true,
        //     ),
        //   ],
        //   defaultValue: DefaultValue(
        //     value: <String, dynamic>{
        //       'id': 1000,
        //       'amount': 10.5,
        //     },
        //   ),
        // );
        // content += SchemaClassGenerator().generateClass(
        //   a,
        //   generateJson: true,
        // );
        // final b = ObjectDataElement(
        //   name: 'Lollipop',
        //   isNullable: true,
        //   defaultValue: DefaultValue(value: {
        //     'count': 10000,
        //     'sugar': {
        //       'id': 156,
        //       'amount': 10.5,
        //     }
        //   }),
        //   properties: [
        //     ObjectProperty(
        //       name: 'id',
        //       item: IntegerDataElement(
        //         name: 'LollipopId',
        //         defaultValue: DefaultValue(value: 100),
        //       ),
        //       isRequired: false,
        //     ),
        //     ObjectProperty(
        //       name: 'count',
        //       item: IntegerDataElement(
        //         name: 'LollipopCount',
        //       ),
        //       isRequired: false,
        //     ),
        //     ObjectProperty(
        //       name: 'sugar',
        //       item: a,
        //       isRequired: false,
        //     ),
        //   ],
        // );
        // content += SchemaClassGenerator().generateClass(
        //   b,
        //   generateJson: true,
        //   inlineJson: true,
        //   additionalCode: [
        //     [
        //       'final toJsonApplication = ',
        //       SchemaToJsonGenerator().generateApplication(b),
        //       ';',
        //     ].joinParts(),
        //     SchemaToJsonGenerator().generateMethod(
        //       b,
        //       name: 'toJsonMethod',
        //       isStatic: true,
        //     ),
        //     [
        //       'final fromJsonApplication = ',
        //       SchemaFromJsonGenerator().generateApplication(b),
        //       ';',
        //     ].joinParts(),
        //     SchemaFromJsonGenerator().generateMethod(
        //       b,
        //       name: 'fromJsonMethod',
        //       isStatic: true,
        //     ),
        //     [
        //       'final toJsonApplicationInline = ',
        //       SchemaToJsonGenerator().generateApplication(
        //         b,
        //         inline: true,
        //       ),
        //       ';',
        //     ].joinParts(),
        //     SchemaToJsonGenerator().generateMethod(
        //       b,
        //       name: 'toJsonMethodInline',
        //       isStatic: true,
        //       inline: true,
        //     ),
        //     [
        //       'final fromJsonApplicationInline = ',
        //       SchemaFromJsonGenerator().generateApplication(
        //         b,
        //         inline: true,
        //       ),
        //       ';',
        //     ].joinParts(),
        //     SchemaFromJsonGenerator().generateMethod(
        //       b,
        //       name: 'fromJsonMethodInline',
        //       isStatic: true,
        //       inline: true,
        //     ),
        //   ].joinMethods(),
        // );
        // final c = ObjectDataElement(
        //   name: 'Ginger',
        //   properties: [
        //     ObjectProperty(
        //       name: 'lollipop',
        //       item: b,
        //       isRequired: false,
        //     ),
        //   ],
        // );
        // content += '\n\n';
        // content += SchemaClassGenerator().generateClass(c);

        await outputFile.writeAsString(content);
      },
    );
  });
}
