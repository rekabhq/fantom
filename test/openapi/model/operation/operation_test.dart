@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
// TODO: more tests are requried for operation model
  group('Operation:', () {
    test(
      'should parse operation from find_pet_by_status.yaml without any errors',
      () async {
        var map = await readJsonOrYamlFile(
            File('test/openapi/model/operation/find_pet_by_status.yaml'));
        var operation = Operation.fromMap(map);
        expect(operation.parameters!.length, map['parameters'].length);
        expect(operation.deprecated, map['deprecated']);
        // expect(operation.operationId, map['operationId']);
        expect(operation.responses!.map!.keys.length,
            map['responses'].keys.length);
      },
    );
  });
}
