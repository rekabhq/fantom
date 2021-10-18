@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/openapi/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  // TODO: more tests are requried for response model
  group('Response', () {
    test(
      'should parse responses object from responses.yaml without any errors',
      () async {
        // with openapi response defined in map
        var map = await readJsonOrYamlFile(
            File('test/openapi/model/response/simple_response.yaml'));
        // when we parse Response from map
        var response = Response.fromMap(map);
        // then
        expect(response.description, response.description);
        expect(response.content?.keys.toSet(), map['content']?.keys.toSet());
        expect(response.headers?.keys.toSet(), map['headers']?.keys.toSet());
      },
    );
  });
}
