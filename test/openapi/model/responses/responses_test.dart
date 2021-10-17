@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/openapi/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
// TODO: more tests are requried for schema model
  group('Responses', () {
    test('should parse responses object from responses.yaml without any errors',
        () async {
      // with openapi responses defined in map
      var map = await readJsonOrYamlFile(
          File('test/openapi/model/responses/responses.yaml'));
      // when we parse Responses from map
      var responses = Responses.fromMap(map);
      // then
      assert(responses.defaultValue != null);
      expect(responses.map!.keys.toSet(), map.keys.toSet()..remove('default'));
    });
  });
}
