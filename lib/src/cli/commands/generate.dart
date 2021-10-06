import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:fantom/src/cli/commands/base_command.dart';
import 'package:fantom/src/exceptions/types.dart';
import 'package:fantom/src/extensions/extensions.dart';
import 'package:fantom/src/utils/constants.dart';
import 'package:fantom/src/utils/logger.dart';
import 'package:fantom/src/utils/utililty_functions.dart';

/// generates network client module from openapi document
///
///
/// examples of how this command can be run :
///
/// generate
///
/// generate -c fantom.yaml
///
/// generate -c some-config.yaml
///
/// generate --path path/to/openapi --output path/to/module/output
///
/// generate --path path/to/openapi --models-output path/output/models --apis-output path/output/apis
///
class GenerateCommand extends BaseCommand<GenerateArgs> {
  GenerateCommand() : super(name: 'generate', description: 'generates network client module from openapi document');

  @override
  void defineCliOptions(ArgParser argParser) {
    argParser.addOption('config', abbr: 'c', help: 'gathers all the argument for generate command from a yaml file');
    argParser.addOption('path', abbr: 'p', help: 'path to the yaml/json openapi file');
    argParser.addOption('output', abbr: 'o', help: 'path where network module should be generated in');
    argParser.addOption('models-output', abbr: 'm', help: 'path where generated models will be stored in');
    argParser.addOption('apis-output', abbr: 'a', help: 'path where generated apis will be stored in');
  }

  @override
  FutureOr<GenerateArgs> createArgumnets(ArgResults argResults) async {
    String? fantomConfigPath;
    String? inputOpenApiFilePath;
    String? outputModulePath;
    String? outputModelsPath;
    String? outputApisPath;
    // getting cli options user entered
    if (argResults.wasParsed('config')) {
      fantomConfigPath = argResults['config'];
    }
    if (argResults.wasParsed('path')) {
      inputOpenApiFilePath = argResults['path'];
    }
    if (argResults.wasParsed('output')) {
      outputModulePath = argResults['output'];
    }
    if (argResults.wasParsed('models-output')) {
      outputModelsPath = argResults['models-output'];
    }
    if (argResults.wasParsed('apis-output')) {
      outputApisPath = argResults['apis-output'];
    }
    if (inputOpenApiFilePath.isNotNullOrBlank) {
      var openApiFile = await getFileInPath(
        path: inputOpenApiFilePath,
        notFoundErrorMessage: 'openapi file path is either not provided or invalid',
      );
      if (outputModelsPath != null && outputApisPath != null) {
        // at this point we don't want to create network client as a module since models and apis path are separate
        var modelsDirectory = await getDirectoryInPath(
          path: outputModelsPath,
          directoryPathIsNotValid: 'Output models directory path is not valid',
        );

        var apisDirectory = await getDirectoryInPath(
          path: outputApisPath,
          directoryPathIsNotValid: 'Output Apis directory path is not valid',
        );

        return GenerateSeparateModelsAndApisArgs(
          inputOpenapiFilePath: openApiFile,
          outputModelsPath: modelsDirectory,
          outputApisPath: apisDirectory,
        );
      } else {
        if (outputModelsPath != null || outputApisPath != null) {
          Log.divider();
          Log.warning(
            'If you want to generate models and api in separate directories in your project instead '
            'of generating the whole fantom client in a module you must provide both (models-output) and (apis-output) '
            'arguments, if not fantom client will be generated in a module if (output) argument is provided',
          );
          Log.divider();
        }
        var outputModuleDirectory = await getDirectoryInPath(
          path: outputModulePath,
          directoryPathIsNotValid: 'Output module directory path is not valid',
        );
        return GenerateAsModuleArgs(inputOpenapiFilePath: openApiFile, outputModulePath: outputModuleDirectory);
      }
    } else if (fantomConfigPath.isNotNullOrBlank) {
      var file = await getFileInPath(
        path: fantomConfigPath,
        notFoundErrorMessage: 'Config file path is invalid',
      );
      var config = await readJsonOrYamlFile(file);
      return _getGenerateArgsFromFantomConfig(config);
    } else {
      var children = kCurrentDirectory.listSync();
      Map<String, dynamic>? config;
      File? fantomFile;
      File? pubspecFile;
      for (var element in children) {
        if (element.path.endsWith('fantom.yaml')) {
          fantomFile = File(element.path);
        }
        if (element.path.endsWith('pubspec.yaml')) {
          pubspecFile = File(element.path);
        }
      }
      if (fantomFile != null) {
        config = await readJsonOrYamlFile(fantomFile);
      } else if (pubspecFile != null) {
        config = await readJsonOrYamlFile(pubspecFile);
      } else {
        throw GenerationConfigNotProvidedException();
      }
      return _getGenerateArgsFromFantomConfig(config);
      // check if current dir has a fantom.yaml or pubspec.yaml with config
      // else throw error
    }
  }

  @override
  FutureOr<int> runCommand(GenerateArgs arguments) async {
    if (arguments is GenerateAsModuleArgs) {
      Log.debug(arguments);
    } else if (arguments is GenerateSeparateModelsAndApisArgs) {
      Log.debug(arguments);
    } else {
      throw Exception(
        'Unknown arguments type for generate command'
        'if you\'re seeing this message please open an issue',
      );
    }
    // TODO - we should return the correct exit code here
    return 0;
  }

  Future<GenerateArgs> _getGenerateArgsFromFantomConfig(Map<String, dynamic> config) async {
    if (!config.containsKey('fantom')) {
      throw GenerationConfigNotProvidedException();
    }
    Map fantomConfig = config['fantom'];
    var path = fantomConfig.getValue('path');
    String? moduleOutput = fantomConfig.getValue('output');
    String? modelsOutput = fantomConfig.getValue('models-output');
    String? apisOutput = fantomConfig.getValue('apis-output');
    var openApiFile = await getFileInPath(
      path: path,
      notFoundErrorMessage: 'openapi file path is either not provided or invalid',
    );
    if (modelsOutput != null && apisOutput != null) {
      // at this point we don't want to create network client as a module since models and apis path are separate
      var modelsDirectory = await getDirectoryInPath(
        path: modelsOutput,
        directoryPathIsNotValid: 'Output models directory path is not valid',
      );

      var apisDirectory = await getDirectoryInPath(
        path: apisOutput,
        directoryPathIsNotValid: 'Output Apis directory path is not valid',
      );

      return GenerateSeparateModelsAndApisArgs(
        inputOpenapiFilePath: openApiFile,
        outputModelsPath: modelsDirectory,
        outputApisPath: apisDirectory,
      );
    } else {
      if (modelsOutput != null || apisOutput != null) {
        Log.divider();
        Log.warning(
          'If you want to generate models and api in separate directories in your project instead '
          'of generating the whole fantom client in a module you must provide both (models-output) and (apis-output) '
          'arguments, if not fantom client will be generated in a module if (output) argument is provided',
        );
        Log.divider();
      }
      var outputModuleDirectory = await getDirectoryInPath(
        path: moduleOutput,
        directoryPathIsNotValid: 'Output module directory path is not valid',
      );
      return GenerateAsModuleArgs(inputOpenapiFilePath: openApiFile, outputModulePath: outputModuleDirectory);
    }
  }
}

class GenerateArgs {}

class GenerateAsModuleArgs extends GenerateArgs {
  final File inputOpenapiFilePath;
  final Directory outputModulePath;

  GenerateAsModuleArgs({
    required this.inputOpenapiFilePath,
    required this.outputModulePath,
  });

  @override
  String toString() {
    var map = {'path': inputOpenapiFilePath, 'output': outputModulePath};
    return map.toString();
  }
}

class GenerateSeparateModelsAndApisArgs extends GenerateArgs {
  final File inputOpenapiFilePath;
  final Directory outputModelsPath;
  final Directory outputApisPath;

  GenerateSeparateModelsAndApisArgs({
    required this.inputOpenapiFilePath,
    required this.outputModelsPath,
    required this.outputApisPath,
  });

  @override
  String toString() {
    var map = {'path': inputOpenapiFilePath, 'models-output': outputModelsPath, 'apis-output': outputApisPath};
    return map.toString();
  }
}
