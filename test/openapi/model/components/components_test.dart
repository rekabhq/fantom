@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  group('Components:', () {
    Map<String, dynamic>? map;

    setUpAll(() async {
      map = await readJsonOrYamlFile(
        File('test/openapi/model/components/simple_components.yaml'),
      );
    });
    tearDownAll(() {
      map = null;
    });
    test(
      'should parse components from simple_components.yaml without any errors',
      () async {
        final components = Components.fromMap(map!['components']);

        expect(components.requestBodies, isNotNull);
        expect(components.requestBodies, isMap);
        expect(components.requestBodies, contains('UserArray'));
        expect(
            components.requestBodies?['UserArray']?.value, isA<RequestBody>());

        expect(components.schemas, isNotNull);
        expect(components.schemas, isMap);
        expect(components.schemas, contains('Foo'));
        expect(components.schemas?['Foo'], isA<Referenceable<Schema>>());
      },
    );
  });
}
