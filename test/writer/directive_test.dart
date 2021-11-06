@Timeout(Duration(minutes: 1))
import 'package:fantom/src/writer/directive.dart';
import 'package:test/test.dart';

void main() {
  group('Directive:', () {
    test(
      'should create relative directive correctly',
      () async {
        // with
        final directiveFilePath =
            'my_package/lib/src/network/data/models/models.dart';
        final filePath = 'my_package/lib/src/network/api.dart';
        final expected = Directive.import('data/models/models.dart');
        // when
        final actual = Directive.relative(
          filePath: filePath,
          directiveFilePath: directiveFilePath,
          type: DirectiveType.import,
        );
        // then
        expect(actual, expected);
      },
    );

    test(
      'should create relative directive that is in parent directories correctly',
      () async {
        // with
        final filePath = 'my_package/lib/src/network/data/models/models.dart';
        final directiveFilePath = 'my_package/lib/src/network/api.dart';
        final expected = Directive.import('../../api.dart');
        // when
        final actual = Directive.relative(
          filePath: filePath,
          directiveFilePath: directiveFilePath,
          type: DirectiveType.import,
        );
        // then
        expect(actual, expected);
      },
    );

    test(
      'should create absolute directive correctly',
      () async {
        // with
        final directiveFilePath = 'my_package/lib/src/network/api.dart';
        final packageName = 'awesome_package';
        final expected =
            Directive.import('package:$packageName/src/network/api.dart');
        // when
        final actual = Directive.absolute(
          directiveFilePath: directiveFilePath,
          type: DirectiveType.import,
          package: packageName,
        );
        // then
        expect(actual, expected);
      },
    );
  });
}
