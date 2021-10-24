@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/writer/dart_package.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';
import 'package:plain_optional/plain_optional.dart' as o;
import 'package:pubspec_yaml/pubspec_yaml.dart' as p;
import 'package:test/test.dart';
import 'package:version/version.dart';

void main() {
  group('CreatePackage:', () {
    final name = 'fantom';
    final generationPath = 'test/writer/packages/';
    final packagePath = '$generationPath/$name';
    final libDirPath = '$packagePath/lib';
    final exampleDirPath = '$packagePath/example';
    final testDirPath = '$packagePath/test';
    final pubspecPath = '$packagePath/pubspec.yaml';
    var packageInfo = DartPackageInfo(
      name: name,
      generationPath: generationPath,
      pubspecInfo: PubspecInfo(
        version: Version(1, 0, 0),
        description: 'this is a very funny library',
        environment: {"sdk": ">=2.14.0 <3.0.0"},
        dependencies: [
          PackageDependencySpec.hosted(HostedPackageDependencySpec(
            package: 'dio',
            version: o.Optional('4.0.1'),
          )),
        ],
      ),
    );

    test(
      'should create a dart package from package info',
      () async {
        //when
        await createDartPackage(packageInfo);
        // assert existense of these files
        expect(Directory(libDirPath).existsSync(), isTrue);
        expect(File(pubspecPath).existsSync(), isTrue);
        expect(Directory(exampleDirPath).existsSync(), isFalse);
        expect(Directory(testDirPath).existsSync(), isFalse);
        // assert content of pubspec.yaml file of created dart package
        print(pubspecPath);
        var pubspecFile = File(pubspecPath);
        var string = await pubspecFile.readAsString();
        print(string);
        var pubspec = p.PubspecYaml.loadFromYamlString(string);
        expect(pubspec.version.valueOr(() => ''),
            packageInfo.pubspecInfo.version.toString());
        expect(pubspec.description.valueOr(() => ''),
            packageInfo.pubspecInfo.description);
        expect(pubspec.name, packageInfo.name);
        expect(pubspec.dependencies, packageInfo.pubspecInfo.dependencies);
      },
    );
  });
}
