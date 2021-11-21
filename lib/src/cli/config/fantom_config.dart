import 'dart:io';

import 'package:args/args.dart';
import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/cli/config/exclude_models.dart';
import 'package:fantom/src/cli/options_values.dart';
import 'package:fantom/src/utils/exceptions.dart';
import 'package:fantom/src/utils/extensions.dart';
import 'package:fantom/src/utils/logger.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:io/io.dart';

class FantomConfig {
  FantomConfig._({
    required this.path,
    required this.apiMethodReturnType,
    required this.excludedComponents,
    required this.excludedPaths,
    this.outputDir,
    this.outputPackageDir,
    this.outputModelsDir,
    this.outputApiDir,
    this.packageName,
  });

  final String path;
  final String apiMethodReturnType;
  final String? outputDir;
  final String? outputPackageDir;
  final String? outputModelsDir;
  final String? outputApiDir;
  final String? packageName;
  final List<String> excludedComponents;
  final ExcludedPaths excludedPaths;

  static Future<FantomConfig> fromArgResults(
    String openapiOrConfigFilePath,
    ArgResults argResults,
  ) async {
    var error = IncorrectFilePathArgument(openapiOrConfigFilePath);
    var file = await getFileInPath(
      path: openapiOrConfigFilePath,
      notFoundErrorMessage: error.message,
    );
    if (await file.isOpenApiFile) {
      String? outputPackagePath;
      String? outputPackageName;
      String? outputModelsPath;
      String? outputApisPath;
      String? outputDirPath;
      String? apiMethodReturnType;
      // getting cli options user entered
      if (argResults.wasParsed(GenerateCommand.optionDir)) {
        outputDirPath = argResults[GenerateCommand.optionDir];
      }
      if (argResults.wasParsed(GenerateCommand.optionPackage)) {
        outputPackagePath = argResults[GenerateCommand.optionPackage];
      }
      if (argResults.wasParsed(GenerateCommand.optionModelDir)) {
        outputModelsPath = argResults[GenerateCommand.optionModelDir];
      }
      if (argResults.wasParsed(GenerateCommand.optionApiDir)) {
        outputApisPath = argResults[GenerateCommand.optionApiDir];
      }
      if (argResults.wasParsed(GenerateCommand.optionPackageName)) {
        outputPackageName = argResults[GenerateCommand.optionPackageName];
      }
      apiMethodReturnType = argResults[GenerateCommand.optionMethodRetuenType];
      return FantomConfig._(
        path: file.path,
        apiMethodReturnType: apiMethodReturnType!,
        outputPackageDir: outputPackagePath,
        packageName: outputPackageName,
        outputModelsDir: outputModelsPath,
        outputApiDir: outputApisPath,
        outputDir: outputDirPath,
        // excluded components & paths can only be read from fantom config file
        excludedComponents: [],
        excludedPaths: ExcludedPaths.fromFantomConfigValues([]),
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
        '(openapi) file path is not provided in fantom config file',
        ExitCode.noInput.code,
      );
    }
    var path = fantomConfig.getValue('openapi');
    String? outputPackagePath =
        fantomConfig.getValue(GenerateCommand.optionPackage);
    String? outputModelsPath =
        fantomConfig.getValue(GenerateCommand.optionModelDir);
    String? outputApisPath =
        fantomConfig.getValue(GenerateCommand.optionApiDir);
    String? outputDirPath = fantomConfig.getValue(GenerateCommand.optionDir);
    String? outputPackageName =
        fantomConfig.getValue(GenerateCommand.optionPackageName);
    String apiMethodReturnType =
        fantomConfig.getValue(GenerateCommand.optionMethodRetuenType) ??
            MethodReturnType.result;
    MethodReturnType.check(apiMethodReturnType);
    List<String> excludedComponentNames =
        ((fantomConfig.getValue('excluded-components') as List?) ?? [])
            .map((e) => e.toString())
            .toList();

    List<String> excludedPathsNames =
        ((fantomConfig.getValue('excluded-paths') as List?) ?? [])
            .map((e) => e.toString())
            .toList();

    final excludedPaths =
        ExcludedPaths.fromFantomConfigValues(excludedPathsNames);

    Log.debug(excludedPaths);
    Log.debug(excludedComponentNames);

    return FantomConfig._(
      path: path,
      apiMethodReturnType: apiMethodReturnType,
      outputPackageDir: outputPackagePath,
      packageName: outputPackageName,
      outputModelsDir: outputModelsPath,
      outputApiDir: outputApisPath,
      outputDir: outputDirPath,
      excludedComponents: excludedComponentNames,
      excludedPaths: excludedPaths,
    );
  }
}
