@Timeout(Duration(minutes: 1))
import 'dart:io';

import 'package:args/args.dart';
import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/utils/constants.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  late ArgParser argParser;
  ArgResults? argResults;
  late GenerateCommand command;
  late String testOpenApiFilePath;
  late Map<String, dynamic> testOpenApi;

  setUp(() async {
    var currentDir = Directory('${kCurrentDirectory.path}/test/cli/testProjectDir');
    testOpenApiFilePath = '${currentDir.path}/petstore.openapi.yaml';
    testOpenApi = await readJsonOrYamlFile(File(testOpenApiFilePath));
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

  group('creating the right GenerateConfig from cli input options', () {
    test('should create GenerateConfig with default directory paths defined for GenerateCommand', () async {
      // with no cli options for output directory is provided
      argResults = argParser.parse(['-p', testOpenApiFilePath]);
      // when we create arguments
      var config = await command.createArguments(argResults!);
      // then created GenerateConfig object should be as expected
      assert(config is GenerateAsPartOfProjectConfig);
      config = config as GenerateAsPartOfProjectConfig;
      expect(config.outputApisDir.path, command.defaultApisOutputPath);
      expect(config.outputModelsDir.path, command.defaultModelsOutputPath);
      expect(config.openApi, testOpenApi);
    });
  });
}
