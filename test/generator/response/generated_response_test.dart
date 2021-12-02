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
    String outputContent = '';
    setUp(() async {
      //
      var openapiMap =
          await readJsonOrYamlFile(File('openapi_files/petstore.openapi.json'));
      openapi = OpenApi.fromMap(openapiMap);
      final componentsGenerator = ComponentsGenerator.createDefault(openapi);

      var map =
          componentsGenerator.generateSchemas(openapi.components!.schemas!);
      map.forEach((ref, component) {
        registerGeneratedComponent(ref, component);
        if (component.isGenerated) {
          outputContent += component.fileContent;
        }
      });
      outputContent += r'''
class Optional<T> {
  final T value;

  const Optional(this.value);
}

// ignore_for_file: prefer_initializing_formals, prefer_null_aware_operators, prefer_if_null_operators, unnecessary_non_null_assertion
''';
      responseClassGenerator = componentsGenerator.responseClassGenerator;
    });

    tearDown(() {
      clearComponentsRegistry();
    });

    // test(
    //   'test response type generation from map of mediaTypes => contents',
    //   () async {
    //     var usersResultResponse =
    //         openapi.components!.responses!.values.toList()[2].value;

    //     var output = responseClassGenerator.generateResponse(
    //         usersResultResponse, 'UsersResult');

    //     var outputFile = File('test/generator/response/response_output.dart');

    //     outputContent += output.fileContent;

    //     await outputFile.writeAsString(outputContent);
    //   },
    // );
  });

  group('ResponseClassGenerator.generateResponses method:', () {
    late ResponseClassGenerator responseClassGenerator;
    late OpenApi openapi;
    String outputContent = '';
    setUp(() async {
      //
      var openapiMap =
          await readJsonOrYamlFile(File('openapi_files/petstore.openapi.json'));
      openapi = OpenApi.fromMap(openapiMap);
      final componentsGenerator = ComponentsGenerator.createDefault(openapi);

      componentsGenerator.generateSchemas(openapi.components!.schemas!).forEach(
        (ref, component) {
          registerGeneratedComponent(ref, component);
          if (component.isGenerated) {
            outputContent += component.fileContent;
          }
        },
      );
      componentsGenerator
          .generateResponses(openapi.components!.responses!)
          .forEach(
        (ref, component) {
          registerGeneratedComponent(ref, component);
          if (component.isGenerated) {
            outputContent += component.fileContent;
          }
        },
      );

      outputContent += r'''
class Optional<T> {
  final T value;

  const Optional(this.value);
}

// ignore_for_file: prefer_initializing_formals, prefer_null_aware_operators, prefer_if_null_operators, unnecessary_non_null_assertion
''';
      responseClassGenerator = componentsGenerator.responseClassGenerator;
    });

    tearDown(() {
      clearComponentsRegistry();
    });

    test(
      'test request_body type generation from map of mediaTypes => contents',
      () async {
        var getPetsResponses = openapi.paths.paths.values.first.get!.responses;

        var output = responseClassGenerator.generateResponses(
          getPetsResponses,
          'PetsResult',
        );

        var outputFile = File('test/generator/response/responses_output.dart');

        outputContent += output.fileContent;

        await outputFile.writeAsString(outputContent);
      },
    );
  });
}
