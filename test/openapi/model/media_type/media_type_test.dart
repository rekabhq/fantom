@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  group('Media Type', () {
    Map<String, dynamic>? map;

    setUpAll(() async {
      map = await readJsonOrYamlFile(
        File('test/openapi/model/media_type/simple_media_type.yaml'),
      );
    });
    tearDownAll(() {
      map = null;
    });
    test(
      'should parse media type from simple_media_type.yaml without any errors',
      () async {
        final mediaType = MediaType.fromMap(map!);

        expect(mediaType.schema, isA<Referenceable<Schema>>());
        expect(mediaType.schema!.value.type, 'object');
        expect(mediaType.schema!.value.properties, isNotNull);
      },
    );
  });
}
