@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/openapi/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  group('Header', () {
    Map<String, dynamic>? map;

    setUpAll(() async {
      map = await readJsonOrYamlFile(
        File('test/openapi/model/header/simple_header.yaml'),
      );
    });
    tearDownAll(() {
      map = null;
    });
    test(
      'should parse header from simple_header.yaml without any errors',
      () async {
        final header = Header.fromMap(map!);

        expect(header.isRequired, isTrue);
        expect(header.style, 'form');
        expect(header.explode, isFalse);
        expect(header.deprecated, isFalse);
        expect(header.allowReserved, isNull);
        expect(header.content, isNull);
        expect(header.schema, isNotNull);
        expect(header.schema?.type, isNotNull);
        expect(header.schema?.type?.isSingle, isTrue);
        expect(header.schema?.type?.single, 'array');
      },
    );
  });
}
