@Timeout(Duration(minutes: 1))

import 'package:fantom/src/generator/api/method/uri_parser.dart';
import 'package:test/test.dart';

void main() {
  group('UriParser:', () {
    final uriParser = MethodUriParser();

    test(
      'should fix baseUrl and path either both or none having / at end and begining \n'
      'like (baseUrl: https://site.com/ ) & (path: /path/to/search)'
      'or (baseUrl: https://site.com ) & (path: path/to/search)',
      () async {
        var baseUrl1 = 'https://site.com/';
        var path1 = '/path/to/search';
        var fixedUrls1 = uriParser.fixBaseUrlAndPath(baseUrl1, path1);
        var fixedBaseUrl1 = fixedUrls1.first;
        var fixedPath1 = fixedUrls1.last;
        print('$fixedBaseUrl1$fixedPath1');
        expect('$fixedBaseUrl1$fixedPath1'.contains('com//path'), isFalse);
        // other variation
        var baseUrl2 = 'https://site.com';
        var path2 = 'path/to/search';
        var fixedUrls2 = uriParser.fixBaseUrlAndPath(baseUrl2, path2);
        var fixedBaseUrl2 = fixedUrls2.first;
        var fixedPath2 = fixedUrls2.last;
        print('$fixedBaseUrl2$fixedPath2');
        expect('$fixedBaseUrl2$fixedPath2'.contains('compath'), isFalse);
      },
    );
  });
}
