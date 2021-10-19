@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/openapi/model/model.dart';
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
        expect(orderSchema.type, isNotNull);
        expect(orderSchema.type?.isSingle, isTrue);
        expect(orderSchema.type?.single, map['type']);
        expect(orderSchema.properties!.length, map['properties'].length);
        expect(orderSchema.properties!.keys.toSet(),
            map['properties'].keys.toSet());
      },
    );
  });
}
