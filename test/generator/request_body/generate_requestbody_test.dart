@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/mediator/mediator/schema/schema_mediator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/sealed_generator_utils.dart';
import 'package:fantom/src/utils/utililty_functions.dart';

import 'package:test/test.dart';

void main() {
  group('request_body tests', () {
    test(
      'test request_body type generation from map of mediaTypes => contents',
      () async {
        var map = await readJsonOrYamlFile(
            File('test/request_body/request_body.json'));
        var openapiMap = await readJsonOrYamlFile(
            File('test/request_body/petstore.openapi.json'));
        var openapi = OpenApi.fromMap(openapiMap);
        Map<String, MediaType> mediaTypes = map.mapValues(
          (e) => MediaType.fromMap(e),
        );
        await generateSealedTypeFromMediaTypes(
          name: 'PetRequestBody',
          mediaTypes: mediaTypes,
          output: File('test/request_body/output.dart'),
          createGeneratedComponentForSchema: (schema) {
            var sm = SchemaMediator();
            var dataElement = sm.convert(
                openApi: openapi, schema: schema, name: 'PetRequestBody');
            if (dataElement is ObjectDataElement) {
              return SchemaClassGenerator().generate(dataElement);
            } else {
              return UnGeneratableSchemaComponent(dataElement: dataElement);
            }
          },
        );
      },
      skip: true,
    );
  });
}
