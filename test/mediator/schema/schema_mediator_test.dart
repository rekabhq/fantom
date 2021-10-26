import 'package:test/test.dart';

void main() {
  // todo: very incomplete ... !
  group('mediator', () {
    group('schema', () {
      test('dummy', () {});

      // test('sample convert 3.0', () async {
      //   final map = await readJsonOrYamlFile(File(
      //     'openapi_files/petstore.openapi.yaml',
      //   ));
      //   final openApi = OpenApiReader.parseOpenApiModel(map);
      //   final mediator = SchemaMediator(compatibility: true);
      //
      //   for (final name in openApi.components!.schemas!.keys) {
      //     final schema = openApi.components!.schemas![name]!;
      //     final element = mediator.convert(
      //       openApi: openApi,
      //       schema: schema,
      //       name: name,
      //     );
      //     expect(element.name, equals(name));
      //   }
      // });
      //
      // test('sample convert 3.1', () async {
      //   final map = await readJsonOrYamlFile(File(
      //     'openapi_files/petstore.openapi-3.1.yaml',
      //   ));
      //   final openApi = OpenApiReader.parseOpenApiModel(map);
      //   final mediator = SchemaMediator(compatibility: false);
      //
      //   for (final name in openApi.components!.schemas!.keys) {
      //     final schema = openApi.components!.schemas![name]!;
      //     final element = mediator.convert(
      //       openApi: openApi,
      //       schema: schema,
      //       name: name,
      //     );
      //     expect(element.name, equals(name));
      //   }
      // });
    });
  });
}
