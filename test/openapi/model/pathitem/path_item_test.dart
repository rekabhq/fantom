@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/openapi/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  group('PathItem', () {
    test(
      'should parse PathItem object from item_post_put.yaml without any errors',
      () async {
        // with openapi response defined in map
        var map = await readJsonOrYamlFile(
            File('test/openapi/model/pathitem/item_post_put.yaml'));
        // when we parse Response from map
        var pathItem = PathItem.fromMap(map);
        // then
        assert(pathItem.post != null);
        assert(pathItem.put != null);
        assert(pathItem.get == null);
        assert(pathItem.delete == null);
        assert(pathItem.head == null);
        assert(pathItem.options == null);
        assert(pathItem.patch == null);
      },
    );
  });
}
