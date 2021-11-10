@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/cli/options_values.dart';
import 'package:fantom/src/generator/utils/generation_data.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:fantom/src/writer/dart_package.dart';
import 'package:fantom/src/writer/file_writer.dart';
import 'package:fantom/src/writer/generatbale_file.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart' as p;
import 'package:test/test.dart';

void main() {
  group('CreatePackage:', () {
    final name = 'client';
    final generationPath = 'test/writer/packages/';
    final packagePath = '$generationPath/$name';
    final libDirPath = '$packagePath/lib';
    final exampleDirPath = '$packagePath/example';
    final testDirPath = '$packagePath/test';
    final pubspecPath = '$packagePath/pubspec.yaml';
    late FantomPackageInfo packageInfo;
    late GenerationData generationData;

    setUpAll(() async {
      generationData = GenerationData(
        config: GenerateAsStandAlonePackageConfig(
          openApi: await readJsonOrYamlFile(
            File('test/openapi/model/openapi/simple_openapi.yaml'),
          ),
          packageName: name,
          outputModuleDir: Directory(generationPath),
          methodReturnType: MethodReturnType.result,
        ),
        models: [
          GeneratableFile(
            fileContent: '''
class ModelA{

}
      ''',
            fileName: 'model_a.dart',
          )
        ],
        apiClass: GeneratableFile(
          fileContent: '''
class ApiClass{

}
      ''',
          fileName: 'api.dart',
        ),
      );

      packageInfo = FantomPackageInfo.fromConfig(
          generationData.config as GenerateAsStandAlonePackageConfig);
    });

    test(
      'should create a dart package from package info',
      () async {
        //when
        await FileWriter(generationData).writeGeneratedFiles();
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
        // assert generated api & model files in lib/
        var actualModelFileNames = Directory(packageInfo.modelsDirPath)
            .listSync()
            .map((e) => e.path.split('/').last);
        for (var model in generationData.models) {
          expect(actualModelFileNames.contains(model.fileName), isTrue);
        }
        var apiFile = File(
            '${packageInfo.apisDirPath}/${generationData.apiClass.fileName}');
        expect(await apiFile.exists(), isTrue);
      },
    );
  });
}
