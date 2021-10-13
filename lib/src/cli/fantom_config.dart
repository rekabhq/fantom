import 'dart:io';

import 'package:args/args.dart';
import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/exceptions/exceptions.dart';
import 'package:fantom/src/extensions/extensions.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:io/io.dart';

class FantomConfig {
  FantomConfig._({
    required this.path,
    this.outputDirPath,
    this.outputModulePath,
    this.outputModelsPath,
    this.outputApisPath,
  });

  final String path;
  final String? outputDirPath;
  final String? outputModulePath;
  final String? outputModelsPath;
  final String? outputApisPath;

  static Future<FantomConfig> fromArgResults(
      String openapiOrConfigFilePath, ArgResults argResults) async {
    var error = IncorrectFilePathArgument(openapiOrConfigFilePath);
    var file = await getFileInPath(
      path: openapiOrConfigFilePath,
      notFoundErrorMessage: error.message,
    );
    if (await file.isOpenApiFile) {
      String? outputModulePath;
      String? outputModelsPath;
      String? outputApisPath;
      String? outputDirPath;
      // getting cli options user entered
      if (argResults.wasParsed(GenerateCommand.optionOutputDir)) {
        outputDirPath = argResults[GenerateCommand.optionOutputDir];
      }
      if (argResults.wasParsed(GenerateCommand.optionOutputModule)) {
        outputModulePath = argResults[GenerateCommand.optionOutputModule];
      }
      if (argResults.wasParsed(GenerateCommand.optionModelsOutput)) {
        outputModelsPath = argResults[GenerateCommand.optionModelsOutput];
      }
      if (argResults.wasParsed(GenerateCommand.optionApisOutput)) {
        outputApisPath = argResults[GenerateCommand.optionApisOutput];
      }
      return FantomConfig._(
        path: file.path,
        outputModulePath: outputModulePath,
        outputModelsPath: outputModelsPath,
        outputApisPath: outputApisPath,
        outputDirPath: outputDirPath,
      );
    } else if (await file.isFantomConfigFile) {
      return fromFile(file);
    } else {
      throw error;
    }
  }

  static Future<FantomConfig> fromFile(File file) async {
    var json = await readJsonOrYamlFile(file);
    if (!json.containsKey('fantom')) {
      throw NoFantomConfigFound(file.path);
    }
    Map fantomConfig = json['fantom'];
    if (!fantomConfig.containsKey('openapi')) {
      throw FantomException(
        '(path) to openapi file is not provided in fantom config file',
        ExitCode.noInput.code,
      );
    }
    var path = fantomConfig.getValue('openapi');
    String? outputModulePath =
        fantomConfig.getValue(GenerateCommand.optionOutputModule);
    String? outputModelsPath =
        fantomConfig.getValue(GenerateCommand.optionModelsOutput);
    String? outputApisPath =
        fantomConfig.getValue(GenerateCommand.optionApisOutput);
    String? outputDirPath =
        fantomConfig.getValue(GenerateCommand.optionOutputDir);
    return FantomConfig._(
      path: path,
      outputModulePath: outputModulePath,
      outputModelsPath: outputModelsPath,
      outputApisPath: outputApisPath,
      outputDirPath: outputDirPath,
    );
  }
}
