@Timeout(Duration(minutes: 1))
import 'package:fantom/src/generator/api/method/uri_parser.dart';
import 'package:test/test.dart';
import 'package:uri/uri.dart';

void main() {
  group('UriTemplate.expand method :', () {
    test(
      'Test Uri Template - simple path parameter',
      () async {
        final path = '/users/{id}';
        final explodedPath = '/users/{id*}';

        final template = UriTemplate(path);
        expect(template.expand({'id': 5}), '/users/5');
        expect(
          template.expand({
            'id': [3, 4, 5]
          }),
          '/users/3,4,5',
        );
        expect(
          template.expand({
            'id': {"role": "admin", "firstName": "Alex"}
          }),
          '/users/role,admin,firstName,Alex',
        );

        final explodeTemplate = UriTemplate(explodedPath);

        expect(explodeTemplate.expand({'id': 5}), '/users/5');
        expect(
          explodeTemplate.expand({
            'id': [3, 4, 5]
          }),
          '/users/3,4,5',
        );
        expect(
          explodeTemplate.expand({
            'id': {"role": "admin", "firstName": "Alex"}
          }),
          '/users/role=admin,firstName=Alex',
        );
      },
    );
    test(
      'Test Uri Template - Label path parameter',
      () async {
        final path = '/users/{.id}';
        final explodedPath = '/users/{.id*}';

        final template = UriTemplate(path);
        expect(template.expand({'id': 5}), '/users/.5');
        expect(
          template.expand({
            'id': [3, 4, 5]
          }),
          '/users/.3,4,5',
        );
        expect(
          template.expand({
            'id': {"role": "admin", "firstName": "Alex"}
          }),
          '/users/.role,admin,firstName,Alex',
        );

        final explodeTemplate = UriTemplate(explodedPath);

        expect(explodeTemplate.expand({'id': 5}), '/users/.5');
        expect(
          explodeTemplate.expand({
            'id': [3, 4, 5]
          }),
          '/users/.3.4.5',
        );
        expect(
          explodeTemplate.expand({
            'id': {"role": "admin", "firstName": "Alex"}
          }),
          '/users/.role=admin.firstName=Alex',
        );
      },
    );
    test(
      'Test Uri Template - Matrix path parameter',
      () async {
        final path = '/users/{;id}';
        final explodedPath = '/users/{;id*}';

        final template = UriTemplate(path);
        expect(template.expand({'id': 5}), '/users/;id=5');
        expect(
          template.expand({
            'id': [3, 4, 5]
          }),
          '/users/;id=3,4,5',
        );
        expect(
          template.expand({
            'id': {"role": "admin", "firstName": "Alex"}
          }),
          '/users/;id=role,admin,firstName,Alex',
        );

        final explodeTemplate = UriTemplate(explodedPath);

        expect(explodeTemplate.expand({'id': 5}), '/users/;id=5');
        expect(
          explodeTemplate.expand({
            'id': [3, 4, 5]
          }),
          '/users/;id=3;id=4;id=5',
        );
        expect(
          explodeTemplate.expand({
            'id': {"role": "admin", "firstName": "Alex"}
          }),
          '/users/;role=admin;firstName=Alex',
        );
      },
    );
    test(
      'Test Uri Template - simple header parameter',
      () async {
        final path = '{id}';
        final explodedPath = '{id*}';

        final template = UriTemplate(path);
        expect(template.expand({'id': 5}), '5');
        expect(
          template.expand({
            'id': [3, 4, 5]
          }),
          '3,4,5',
        );
        expect(
          template.expand({
            'id': {"role": "admin", "firstName": "Alex"}
          }),
          'role,admin,firstName,Alex',
        );

        final explodeTemplate = UriTemplate(explodedPath);

        expect(explodeTemplate.expand({'id': 5}), '5');
        expect(
          explodeTemplate.expand({
            'id': [3, 4, 5]
          }),
          '3,4,5',
        );
        expect(
          explodeTemplate.expand({
            'id': {"role": "admin", "firstName": "Alex"}
          }),
          'role=admin,firstName=Alex',
        );
      },
    );
    test(
      'Test Uri Template - form query parameter',
      () async {
        final path = '/users{?id}';
        final explodedPath = '/users{?id*}';

        final template = UriTemplate(path);
        expect(template.expand({'id': 5}), '/users?id=5');
        expect(
          template.expand({
            'id': [3, 4, 5]
          }),
          '/users?id=3,4,5',
        );
        expect(
          template.expand({
            'id': {"role": "admin", "firstName": "Alex"}
          }),
          '/users?id=role,admin,firstName,Alex',
        );

        final explodeTemplate = UriTemplate(explodedPath);

        expect(explodeTemplate.expand({'id': 5}), '/users?id=5');
        expect(
          explodeTemplate.expand({
            'id': [3, 4, 5]
          }),
          '/users?id=3&id=4&id=5',
        );
        expect(
          explodeTemplate.expand({
            'id': {"role": "admin", "firstName": "Alex"}
          }),
          '/users?role=admin&firstName=Alex',
        );
      },
    );

    test(
      'Test Uri Template - spaceDelimited query parameter',
      () async {
        // we only can use space delimited when we have list

        final path = '/users{?id,numbers}';
        final explodedPath = '/users{?id*,numbers*}';

        final template = UriTemplate(path);
        expect(
          template.expand({
            'id': [3, 4, 5],
            'numbers': [1, 2, 3]
          }).replaceAll(',', '%20'),
          '/users?id=3%204%205&numbers=1%202%203',
        );

        final explodeTemplate = UriTemplate(explodedPath);

        expect(
          explodeTemplate.expand({
            'id': [3, 4, 5],
            'numbers': [1, 2, 3]
          }),
          '/users?id=3&id=4&id=5&numbers=1&numbers=2&numbers=3',
        );
      },
    );
    test(
      'Test Uri Template - pipeDelimited query parameter',
      () async {
        // we only can use space delimited when we have list

        final path = '/users{?id}';
        final explodedPath = '/users{?id*}';

        final template = UriTemplate(path);
        expect(
          template.expand({
            'id': [3, 4, 5]
          }).replaceAll(',', '|'),
          '/users?id=3|4|5',
        );

        final explodeTemplate = UriTemplate(explodedPath);

        expect(
          explodeTemplate.expand({
            'id': [3, 4, 5]
          }),
          '/users?id=3&id=4&id=5',
        );
      },
    );
  });

  group('UriParser.fixBaseUrlAndPath method :', () {
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

  group('UriParser.parseUri method :', () {
    final uriParser = MethodUriParser();

    test(
      'should put primitive path parameters in uri template using simple style and parse uri correctly',
      () {
        //with
        var pathURL = '/user/{id}';
        //when
        var uri = uriParser.parseUri(
          pathURL: pathURL,
          pathParameters: [UriParam.primitive('id', 5, 'simple')],
          queryParameters: [],
        );
        //then
        expect(uri.toString(), '/user/5');
      },
    );

    test(
      'should put array path parameters in uri template using simple style and parse uri correctly',
      () {
        //with
        var pathURL = '/user/{id}';
        //when
        var uri = uriParser.parseUri(
          pathURL: pathURL,
          pathParameters: [
            UriParam.array('id', ['3', '4', '5'], 'simple', false),
          ],
          queryParameters: [],
        );
        //then
        expect(uri.toString(), '/user/3,4,5');
      },
    );

    test(
      'should put array path parameters in uri template using simple style also exploded and parse uri correctly',
      () {
        //with
        var pathURL = '/user/{id}';
        //when
        var uri = uriParser.parseUri(
          pathURL: pathURL,
          pathParameters: [
            UriParam.array('id', ['3', '4', '5'], 'simple', true),
          ],
          queryParameters: [],
        );
        //then
        expect(uri.toString(), '/user/3,4,5');
      },
    );

    test(
      'should put object path parameters in uri template using simple style and parse uri correctly',
      () {
        //with
        var pathURL = '/user/{id}';
        //when
        var uri = uriParser.parseUri(
          pathURL: pathURL,
          pathParameters: [
            UriParam.object(
                'id', {"role": "admin", "firstName": "Alex"}, 'simple', false)
          ],
          queryParameters: [],
        );
        //then
        expect(
          uri.toString(),
          '/user/role,admin,firstName,Alex',
        );
      },
    );

    test(
      'should put object path parameters in uri template using simple style also explode and parse uri correctly',
      () {
        //with
        var pathURL = '/user/{id*}';
        //when
        var uri = uriParser.parseUri(
          pathURL: pathURL,
          pathParameters: [
            UriParam.object(
                'id', {"role": "admin", "firstName": "Alex"}, 'simple', false)
          ],
          queryParameters: [],
        );
        //then
        expect(
          uri.toString(),
          '/user/role=admin,firstName=Alex',
        );
      },
    );

    test(
      'should first override template matcher to be explode'
      'should put object path parameters in uri template using simple style also explode and parse uri correctly',
      () {
        //with
        var pathURL = '/user/{id}';
        //when
        var uri = uriParser.parseUri(
          pathURL: pathURL,
          pathParameters: [
            UriParam.object(
              'id',
              {"role": "admin", "firstName": "Alex"},
              'simple',
              true,
            )
          ],
          queryParameters: [],
        );
        //then
        expect(
          uri.toString(),
          '/user/role=admin,firstName=Alex',
        );
      },
    );

    test(
      'should put query parameter in uri template with form style',
      () {
        //with
        var pathURL = '/users';
        //when
        var uri = uriParser.parseUri(
          pathURL: pathURL,
          pathParameters: [],
          queryParameters: [UriParam.primitive('id', 5, 'form')],
        );
        //then
        expect(
          uri.toString(),
          '/users?id=5',
        );
      },
    );

    test(
      'should put array type query parameter in uri template with form style',
      () {
        //with
        var pathURL = '/users';
        //when
        var uri = uriParser.parseUri(
          pathURL: pathURL,
          pathParameters: [],
          queryParameters: [
            UriParam.array('id', [3, 4, 5], 'form', true)
          ],
        );
        //then
        expect(
          uri.toString(),
          '/users?id=3&id=4&id=5',
        );
      },
    );

    test(
      'should put object type query parameter in uri template with form style',
      () {
        //with
        var pathURL = '/users';
        //when
        var uri = uriParser.parseUri(
          pathURL: pathURL,
          pathParameters: [],
          queryParameters: [
            UriParam.object('id', {"role": "admin", "age": 14}, 'form', true)
          ],
        );
        //then
        expect(
          uri.toString(),
          '/users?role=admin&age=14',
        );
      },
    );
  });
}
