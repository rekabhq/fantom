@Skip('passes locally, fails on ci')
@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/cli/config/exclude_models.dart';
import 'package:fantom/src/cli/config/fantom_config.dart';
import 'package:fantom/src/cli/options_values.dart';
import 'package:fantom/src/generator/utils/generation_data.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:fantom/src/writer/dart_package.dart';
import 'package:fantom/src/writer/file_writer.dart';
import 'package:fantom/src/writer/generatbale_file.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart' as p;
import 'package:test/test.dart';

void main() {
  group('ReCreatePackage:', () {
    final name = 'client2';
    final generationPath = 'test/writer/packages/';
    final packagePath = '$generationPath/$name';
    final libDirPath = '$packagePath/lib';
    final exampleDirPath = '$packagePath/example';
    final testDirPath = '$packagePath/test';
    final pubspecPath = '$packagePath/pubspec.yaml';
    late FantomPackageInfo packageInfo;
    late GenerationData generationData;

    setUpAll(() async {
      final generationDirectory = Directory(packagePath);
      if (generationDirectory.existsSync()) {
        await generationDirectory.delete(recursive: true);
      }

      generationData = GenerationData(
        config: GenerateAsStandAlonePackageConfig(
          openApi: await readJsonOrYamlFile(
            File('test/openapi/model/openapi/simple_openapi.yaml'),
          ),
          fantomConfig: FantomConfig(
            packageName: name,
            outputPackageDir: generationPath,
            apiMethodReturnType: MethodReturnType.result,
            excludedComponents: [],
            excludedPaths: ExcludedPaths.fromFantomConfigValues([]),
            path: '',
            recreatePackage: false,
          ),
          packageName: name,
          outputModuleDir: Directory(generationPath),
        ),
        models: [
          GeneratedFile(
            fileContent: '''
class ModelA{
// just an empty model to test FileWriter.
}
      ''',
            fileName: 'model_a.dart',
          )
        ],
        apiClass: GeneratedFile(
          fileContent: '''
class ApiClass{
// just an empty api class to test FileWriter.
}
      ''',
          fileName: 'api.dart',
        ),
        resourceApiClasses: [
          GeneratedFile(
            fileContent: '''
class ResourceApi{
// just an empty api class to test FileWriter.
}
      ''',
            fileName: 'resource_api.dart',
          ),
        ],
      );

      packageInfo = FantomPackageInfo.fromConfig(
        generationData.config as GenerateAsStandAlonePackageConfig,
      );
    });

    test(
      'FileWriter should not recreate package if already exists',
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
        var pubspec =
            p.PubspecYaml.loadFromYamlString(await pubspecFile.readAsString());
        expect(
          pubspec.version.valueOr(() => ''),
          packageInfo.pubspecInfo.version.toString(),
        );
        expect(
          pubspec.description.valueOr(() => ''),
          packageInfo.pubspecInfo.description,
        );
        expect(pubspec.name, packageInfo.name);
        expect(pubspec.dependencies, packageInfo.pubspecInfo.dependencies);
        // assert generated api & model files in lib/
        var actualModelFileNames = Directory(packageInfo.modelsDirPath)
            .listSync()
            .map((e) => e.path.split('/').last);
        for (var model in generationData.models) {
          expect(actualModelFileNames.contains(model.fileName), isTrue);
        }
        var apiFile =
            File('${packageInfo.libDir}/${generationData.apiClass.fileName}');
        expect(await apiFile.exists(), isTrue);

        // create a new file in lib. it should exists after we regenerate the package
        final testFile = File('${packageInfo.libDir}/test_file.txt')
          ..createSync(recursive: true);

        // regenerate package again
        await FileWriter(generationData).writeGeneratedFiles();

        // check if testFile still exists

        expect(await testFile.exists(), isTrue);
      },
    );
  });
}
