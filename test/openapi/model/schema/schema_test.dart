@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
// TODO: more tests are requried for schema model
  group('Schema:', () {
    test(
      'should parse order object from order.yaml without any errors',
      () async {
        var map = await readJsonOrYamlFile(
            File('test/openapi/model/schema/order.yaml'));
        var orderSchema = Schema.fromMap(map);
        expect(orderSchema.type, map['type']);
        expect(orderSchema.properties!.length, map['properties'].length);
        expect(orderSchema.properties!.keys.toSet(),
            map['properties'].keys.toSet());
      },
    );
  });
}
