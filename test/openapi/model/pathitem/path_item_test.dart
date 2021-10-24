@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  group('PathItem:', () {
    test(
      'should parse PathItem object from item_post_put.yaml without any errors',
      () async {
        // with openapi response defined in map
        var map = await readJsonOrYamlFile(
            File('test/openapi/model/pathitem/item_post_put.yaml'));
        // when we parse Response from map
        var pathItem = PathItem.fromMap(map);
        // then
        expect(pathItem.post, isNotNull);
        expect(pathItem.put, isNotNull);
        expect(pathItem.get, isNull);
        expect(pathItem.delete, isNull);
        expect(pathItem.head, isNull);
        expect(pathItem.options, isNull);
        expect(pathItem.patch, isNull);
      },
    );
  });
}
