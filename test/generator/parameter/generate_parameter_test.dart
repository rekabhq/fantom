import 'dart:io';

import 'package:fantom/src/generator/components/component_generator.dart';
import 'package:fantom/src/generator/components/components.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/parameter/parameter_class_generator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  group(
    'ParameterClassGenerator: ',
    () {
      late ParameterClassGenerator parameterClassGenerator;
      late OpenApi openapi;
      setUpAll(() async {
        final openapiMap = await readJsonOrYamlFile(
          File('openapi_files/petstore.openapi.json'),
        );

        openapi = OpenApi.fromMap(openapiMap);
        final componentsGenerator = ComponentsGenerator.createDefault(openapi);

        final map = componentsGenerator.generateSchemas(
          openapi.components!.schemas!,
        );

        map.forEach((ref, component) {
          registerGeneratedComponent(ref, component);
        });

        parameterClassGenerator = componentsGenerator.parameterClassGenerator;
      });

      test(
        'test generate method of ParameterClassGenerator - array schema',
        () async {
          final parameter = openapi.components?.parameters?['Status'];

          expect(parameter, isNotNull);
          expect(parameter, isA<Referenceable<Parameter>>());
          expect(parameter!.isValue, isTrue);

          final generatedParameter = parameterClassGenerator.generate(
            openapi,
            parameter.value,
            'Status',
          );

          expect(generatedParameter, isA<UnGeneratableParameterComponent>());

          print('type: ${generatedParameter.runtimeType}');

          print('isSchema: ${generatedParameter.isSchema}');
          print('isContent: ${generatedParameter.isContent}');
          print('isGenerated: ${generatedParameter.isGenerated}');

          print(
              'schemaType: ${generatedParameter.schemaComponent.runtimeType}');
          print(
              'schemaType: ${generatedParameter.schemaComponent?.isGenerated}');

          print(
              'dataElement: ${generatedParameter.schemaComponent!.dataElement}');
          print(
              'dataElement Type: ${generatedParameter.schemaComponent!.dataElement.type}');

          expect(generatedParameter.isSchema, isTrue);
          expect(generatedParameter.isGenerated, isFalse);

          expect(generatedParameter.schemaComponent, isNotNull);
          expect(generatedParameter.schemaComponent?.isGenerated, isFalse);

          expect(
            generatedParameter.schemaComponent?.dataElement,
            isA<ArrayDataElement>(),
          );
        },
      );

      test(
        'test generate method of ParameterClassGenerator - primitive schema',
        () async {
          final parameter = openapi.components?.parameters?['Id'];

          expect(parameter, isNotNull);
          expect(parameter, isA<Referenceable<Parameter>>());
          expect(parameter!.isValue, isTrue);

          final generatedParameter = parameterClassGenerator.generate(
            openapi,
            parameter.value,
            'Id',
          );
          print('type: ${generatedParameter.runtimeType}');

          print('isSchema: ${generatedParameter.isSchema}');
          print('isContent: ${generatedParameter.isContent}');
          print('isGenerated: ${generatedParameter.isGenerated}');

          print(
              'schemaType: ${generatedParameter.schemaComponent.runtimeType}');
          print(
              'schemaType: ${generatedParameter.schemaComponent?.isGenerated}');

          print(
              'dataElement: ${generatedParameter.schemaComponent!.dataElement}');
          print(
              'dataElement Type: ${generatedParameter.schemaComponent!.dataElement.type}');

          expect(generatedParameter.isSchema, isTrue);
          expect(generatedParameter.isGenerated, isFalse);

          expect(generatedParameter.schemaComponent, isNotNull);
          expect(generatedParameter.schemaComponent?.isGenerated, isFalse);

          expect(
            generatedParameter.schemaComponent?.dataElement,
            isA<IntegerDataElement>(),
          );
        },
      );

      test(
        'test generate method of ParameterClassGenerator - object schema',
        () async {
          final parameter = openapi.components?.parameters?['User'];

          expect(parameter, isNotNull);
          expect(parameter, isA<Referenceable<Parameter>>());
          expect(parameter!.isValue, isTrue);

          final generatedParameter = parameterClassGenerator.generate(
            openapi,
            parameter.value,
            'Id',
          );
          print('type: ${generatedParameter.runtimeType}');

          print('isSchema: ${generatedParameter.isSchema}');
          print('isContent: ${generatedParameter.isContent}');
          print('isGenerated: ${generatedParameter.isGenerated}');

          print(
              'schemaType: ${generatedParameter.schemaComponent.runtimeType}');
          print(
              'schemaType: ${generatedParameter.schemaComponent?.isGenerated}');

          print('fileName: ${generatedParameter.fileName}');
          print('fileContent: ${generatedParameter.fileContent}');

          print(
              'dataElement: ${generatedParameter.schemaComponent!.dataElement}');
          print(
              'dataElement Type: ${generatedParameter.schemaComponent!.dataElement.type}');

          expect(generatedParameter.isSchema, isTrue);
          expect(generatedParameter.isGenerated, isTrue);

          expect(generatedParameter.schemaComponent, isNotNull);
          expect(generatedParameter.schemaComponent?.isGenerated, isTrue);

          expect(
            generatedParameter.schemaComponent?.dataElement,
            isA<ObjectDataElement>(),
          );
        },
      );
    },
  );
}
