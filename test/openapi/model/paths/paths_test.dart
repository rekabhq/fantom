@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/openapi/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  group('Paths', () {
    test('should parse Paths object from paths.yaml without any errors',
        () async {
      // with openapi response defined in map
      var map =
          await readJsonOrYamlFile(File('test/openapi/model/paths/paths.yaml'));
      // when we parse Response from map
      var paths = Paths.fromMap(map);
      // then
      expect(paths.paths.keys.toSet(), map.keys.toSet());
    });
  });
}
