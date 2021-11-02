@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/generator/components/component_generator.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/request_body/requestbody_class_generator.dart';
import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/mediator/mediator/schema/schema_mediator.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';

import 'package:test/test.dart';

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

        var content = output.fileContent;

        // todo : fix ...

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
            final component = SchemaClassGenerator().generate(
              element as ObjectDataElement,
            );
            content += component.fileContent;
          }
        }

        content += r'''
class Optional<T> {
  final T value;

  const Optional(this.value);
}

// ignore_for_file: prefer_initializing_formals, prefer_null_aware_operators, prefer_if_null_operators, unnecessary_non_null_assertion
''';

        content = content.replaceAll('dynamic?', 'dynamic');

        await outputFile.writeAsString(content);
      },
    );
  });
}
