@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  group('Encoding:', () {
    Map<String, dynamic>? map;

    setUpAll(() async {
      map = await readJsonOrYamlFile(
        File('test/openapi/model/encoding/simple_encoding.yaml'),
      );
    });
    tearDownAll(() {
      map = null;
    });
    test(
      'should parse encoding from simple_encoding.yaml without any errors',
      () async {
        final encoding = Encoding.fromMap(map!);

        expect(encoding.contentType, contains('image/png'));
        expect(encoding.contentType, contains('image/jpeg'));

        final headers = encoding.headers;
        expect(headers, isNotNull);
        expect(encoding.headers, isNotEmpty);
        expect(
            encoding.headers?.containsKey('X-Rate-Limit-Limit'), equals(true));
        expect(headers?['X-Rate-Limit-Limit']?.isValue, isTrue);
        expect(headers?['X-Rate-Limit-Limit']?.value, isA<Header>());
      },
    );
  });
}
