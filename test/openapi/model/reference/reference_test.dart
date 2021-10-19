@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/openapi/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  group('Reference:', () {
    test(
      'should parse Reference object from reference.yaml without any errors',
      () async {
        // with openapi response defined in map
        var map = await readJsonOrYamlFile(
            File('test/openapi/model/reference/reference.yaml'));
        // when we parse Response from map
        var reference = Reference.fromMap(map);
        // then
        expect(reference.ref, map['\$ref']);
      },
    );
  });
}
