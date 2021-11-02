@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/generator/components/component_generator.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/response/response_class_generator.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';

import 'package:test/test.dart';

void main() {
  group('ResponseClassGenerator.generateResponse method:', () {
    late ResponseClassGenerator responseClassGenerator;
    late OpenApi openapi;
    setUpAll(() async {
      //
      var openapiMap =
          await readJsonOrYamlFile(File('openapi_files/petstore.openapi.json'));
      openapi = OpenApi.fromMap(openapiMap);
      final componentsGenerator = ComponentsGenerator.createDefault(openapi);

      var map =
          componentsGenerator.generateSchemas(openapi.components!.schemas!);
      map.forEach((ref, component) {
        registerGeneratedComponent(ref, component);
      });
      responseClassGenerator = componentsGenerator.responseClassGenerator;
    });

    test(
      'test request_body type generation from map of mediaTypes => contents',
      () async {
        var response = openapi.components!.responses!.values.first.value;

        var output = responseClassGenerator.generate(response, 'Pet');

        var outputFile = File('test/generator/response/output.dart');

        var content = output.fileContent;

        content += r'''
class Optional<T> {
  final T value;

  const Optional(this.value);
}

// ignore_for_file: prefer_initializing_formals, prefer_null_aware_operators, prefer_if_null_operators, unnecessary_non_null_assertion
''';

        await outputFile.writeAsString(content);
      },
    );
  });
}
