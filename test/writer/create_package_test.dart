@Timeout(Duration(minutes: 1))
import 'package:fantom/src/writer/dart_package.dart';
import 'package:test/test.dart';
import 'package:version/version.dart';

void main() {
  group('CreatePackage:', () {
    var packageInfo = DartPackageInfo(
      name: 'fun_lib',
      generationPath: 'test/writer/packages/',
      pubspecInfo: PubspecInfo(
        version: Version(1, 0, 0),
        description: 'this is a very funny library',
        environment: {"sdk": ">=2.14.0 <3.0.0"},
        dependencies: {
          "args": "^2.3.0",
          "console": "^4.1.0",
          "cli_util": "^0.3.4",
        },
      ),
    );

    test(
      'should create a dart package from package info',
      () async {
        await createDartPackage(packageInfo);
      },
    );
  });
}
