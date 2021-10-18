@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/openapi/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  group('Parameter', () {
    Map<String, dynamic>? map;

    setUpAll(() async {
      map = await readJsonOrYamlFile(
        File('test/openapi/model/parameter/find_pet_by_status_param.yaml'),
      );
    });
    tearDownAll(() {
      map = null;
    });
    test(
      'should parse parameter from find_pet_by_status_param.yaml without any errors',
      () async {
        final parameter = Parameter.fromMap(map!);

        expect(parameter.name, 'status');
        expect(parameter.location, 'query');
        expect(parameter.isRequired, true);
        expect(parameter.style, 'form');
        expect(parameter.explode, false);
        expect(parameter.schema, isNotNull);
        expect(parameter.deprecated, isNull);
        expect(parameter.content, isNull);
        expect(parameter.allowEmptyValue, isNull);
        expect(parameter.allowReserved, isNull);
      },
    );
  });
}
