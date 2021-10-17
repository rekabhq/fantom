@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:args/args.dart';
import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/cli/fantom_config.dart';
import 'package:fantom/src/utils/constants.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  late ArgParser argParser;
  ArgResults? argResults;
  late GenerateCommand command;
  late String testOpenApiFilePath;
  late Map<String, dynamic> testOpenApi;
  late Directory currentDir;
  late FantomConfig testFantomConfig;
  late FantomConfig testPubspecConfig;

  setUp(() async {
    currentDir = Directory('${kCurrentDirectory.path}/test/cli/testProjectDir');
    testOpenApiFilePath = '${currentDir.path}/petstore.openapi.yaml';
    testOpenApi = await readJsonOrYamlFile(File(testOpenApiFilePath));
    testFantomConfig = await FantomConfig.fromFile(
        File('${currentDir.path}/fantom-config.yaml'));
    testPubspecConfig =
        await FantomConfig.fromFile(File('${currentDir.path}/pubspec.yaml'));
    command = GenerateCommand(
      currentDirectory: currentDir,
      defaultModelsOutputPath: '${currentDir.path}/gen/lib/src/models',
      defaultApisOutputPath: '${currentDir.path}/gen/lib/src/apis',
    );
    argParser = command.argParser;
  });

  tearDown(() {
    argResults = null;
  });

  group('GenerateCommand:', () {
    void insertOptionsForGenerateCommand(List<String> options) {
      argResults = argParser.parse(options);
    }

    test(
        'should create GenerateConfig with default directory paths defined for GenerateCommand',
        () async {
      // with no cli input options for output directory provided
      insertOptionsForGenerateCommand([testOpenApiFilePath]);
      // when we create a GenerateConfig as arguments
      var config = await command.createArguments(argResults!);
      // then created GenerateConfig object should be as expected
      assert(config is GenerateAsPartOfProjectConfig);
      config = config as GenerateAsPartOfProjectConfig;
      expect(config.outputApisDir.path, command.defaultApisOutputPath);
      expect(config.outputModelsDir.path, command.defaultModelsOutputPath);
      expect(config.openApi, testOpenApi);
    });

    test(
        'should create GenerateConfig as GenerateAsStandAlonePackageConfig with provided cli options',
        () async {
      // with cli input option (-o) for output directory provided
      var moduleOutputPath = '${currentDir.path}/gen/module';
      insertOptionsForGenerateCommand(
          [testOpenApiFilePath, '-p', moduleOutputPath]);
      // when we create a GenerateConfig as arguments
      var config = await command.createArguments(argResults!);
      // then created GenerateConfig object should be as expected
      assert(config is GenerateAsStandAlonePackageConfig);
      config = config as GenerateAsStandAlonePackageConfig;
      expect(config.outputModuleDir.path, moduleOutputPath);
      expect(config.openApi, testOpenApi);
    });

    test(
        'should create GenerateConfig as GenerateAsPartOfProjectConfig with provided cli options',
        () async {
      // with different cli input options provided for both models & apis ouput directory
      var modelsOutputPath = '${currentDir.path}/gen/models';
      var apisOutputPath = '${currentDir.path}/gen/apis';
      insertOptionsForGenerateCommand(
          [testOpenApiFilePath, '-m', modelsOutputPath, '-a', apisOutputPath]);
      // when we create a GenerateConfig as arguments
      var config = await command.createArguments(argResults!);
      // then created GenerateConfig object should be as expected
      assert(config is GenerateAsPartOfProjectConfig);
      config = config as GenerateAsPartOfProjectConfig;
      expect(config.outputModelsDir.path, modelsOutputPath);
      expect(config.outputApisDir.path, apisOutputPath);
      expect(config.openApi, testOpenApi);
    });

    test(
      'should create GenerateConfig as GenerateAsPartOfProjectConfig '
      'with a single directory provided for generated code',
      () async {
        // with different cli input options provided for both models & apis ouput directory
        var outputDir = '${currentDir.path}/gen/dir';
        insertOptionsForGenerateCommand([testOpenApiFilePath, '-d', outputDir]);
        // when we create a GenerateConfig as arguments
        var config = await command.createArguments(argResults!);
        // then created GenerateConfig object should be as expected
        assert(config is GenerateAsPartOfProjectConfig);
        config = config as GenerateAsPartOfProjectConfig;
        expect(config.outputModelsDir.path, '$outputDir/model');
        expect(config.outputApisDir.path, '$outputDir/api');
        expect(config.openApi, testOpenApi);
      },
    );

    test(
        'should create GenerateConfig as GenerateAsPartOfProjectConfig with provided fantom config',
        () async {
      // with a config file provided in cli options (-c)
      var fantomYamlFile = '${currentDir.path}/fantom-config.yaml';
      insertOptionsForGenerateCommand([fantomYamlFile]);
      // when we create a GenerateConfig as arguments
      var config = await command.createArguments(argResults!);
      // then created GenerateConfig object should be as expected
      assert(config is GenerateAsPartOfProjectConfig);
      config = config as GenerateAsPartOfProjectConfig;
      expect(config.outputModelsDir.path, testFantomConfig.outputModelsDir);
      expect(config.outputApisDir.path, testFantomConfig.outputApiDir);
      expect(config.openApi, testOpenApi);
    });

    test(
        'should create GenerateConfig from pubspec.yaml file in current dir when no cli options is provided',
        () async {
      // with absolutly no options provided
      insertOptionsForGenerateCommand([]);
      // when we create a GenerateConfig as arguments
      var config = await command.createArguments(argResults!);
      // then created GenerateConfig object should be as expected
      assert(config is GenerateAsPartOfProjectConfig);
      config = config as GenerateAsPartOfProjectConfig;
      expect(config.outputModelsDir.path, testPubspecConfig.outputModelsDir);
      expect(config.outputApisDir.path, testPubspecConfig.outputApiDir);
      expect(config.openApi, testOpenApi);
    });
  });
}
