@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  group('Open Api Base', () {
    Map<String, dynamic>? map;

    setUpAll(() async {
      map = await readJsonOrYamlFile(
        File('test/openapi/model/openapi/simple_openapi.yaml'),
      );
    });
    tearDownAll(() {
      map = null;
    });
    test(
      'should open api model from simple_openapi.yaml without any errors',
      () async {
        final openApi = OpenApi.fromMap(map!);

        expect(openApi.openapi, equals('3.0.0'));

        expect(openApi.paths, isA<Paths>());
        expect(openApi.paths.paths, isNotEmpty);
        expect(openApi.paths.paths, contains('/pet'));

        expect(openApi.components, isA<Components>());
        expect(openApi.components, isNotNull);
        expect(openApi.components?.schemas, isNotNull);
        expect(openApi.components?.schemas, contains('Order'));
      },
    );
  });
}
