import 'dart:io';

import 'package:fantom/src/mediator/mediator/schema/schema_mediator.dart';
import 'package:fantom/src/reader/openapi_reader.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  // todo: very incomplete ...
  group('mediator', () {
    group('schema', () {
      test('sample convert', () async {
        final map = await readJsonOrYamlFile(File(
          'openapi_files/petstore.openapi.yaml',
        ));
        final openApi = OpenApiReader.parseOpenApiModel(map);
        final mediator = SchemaMediator(compatibility: false);

        for (final name in openApi.components!.schemas!.keys) {
          final schema = openApi.components!.schemas![name]!;
          final element = mediator.convert(
            openApi: openApi,
            schema: schema,
            name: name,
          );
          expect(element.name, equals(name));
        }
      });
    });
  });
}
