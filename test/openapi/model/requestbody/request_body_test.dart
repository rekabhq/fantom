@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
// TODO: more tests are requried for schema model
  group('RequestBody:', () {
    test(
      'should parse RequstBody object from request_body.yaml without any errors',
      () async {
        // with openapi response defined in map
        var map = await readJsonOrYamlFile(
            File('test/openapi/model/requestbody/request_body.yaml'));
        // when we parse Response from map
        var requestBody = RequestBody.fromMap(map);
        // then
        expect(requestBody.isRequired, map['required']);
        expect(requestBody.content.keys.toSet(), map['content'].keys.toSet());
      },
    );
  });
}
