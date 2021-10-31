@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/generator/components/component_generator.dart';
import 'package:fantom/src/generator/components/components_collection.dart';
import 'package:fantom/src/generator/request_body/requestbody_class_generator.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';

import 'package:test/test.dart';

void main() {
  group('RequestBodyClassGenerator: ', () {
    late RequestBodyClassGenerator requestBodyClassGenerator;
    late OpenApi openapi;
    setUpAll(() async {
      print('');
      var openapiMap = await readJsonOrYamlFile(
          File('test/generator/request_body/petstore.openapi.json'));
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

        var output = requestBodyClassGenerator.generate(
          typeName: 'PetRequestBody',
          subTypeName: 'Pet',
          generatedSchemaTypeName: 'PetBody',
          requestBody: requestBody,
        );

        var outputFile = File('test/generator/request_body/output.dart');
        await outputFile.writeAsString(output.fileContent);
      },
    );
  });
}
