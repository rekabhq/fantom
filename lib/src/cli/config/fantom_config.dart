import 'dart:io';

import 'package:args/args.dart';
import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/cli/config/exclude_models.dart';
import 'package:fantom/src/cli/downloader.dart';
import 'package:fantom/src/cli/options_values.dart';
import 'package:fantom/src/utils/exceptions.dart';
import 'package:fantom/src/utils/extensions.dart';
import 'package:fantom/src/utils/logger.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:io/io.dart';

class FantomConfig {
  FantomConfig({
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
    String openapiOrConfigFile,
    ArgResults argResults,
  ) async {
    var error = IncorrectFilePathArgument(openapiOrConfigFile);
    late File file;
    if (openapiOrConfigFile.isValidUrl) {
      final downloader = FileDownloader(
        fileUrl: openapiOrConfigFile,
        savePath: argResults[GenerateCommand.optionDownloadPath],
      );
      file = await downloader.download();
    } else {
      file = await getFileInPath(
        path: openapiOrConfigFile,
        notFoundErrorMessage: error.message,
      );
    }
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
      return FantomConfig(
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

    var openapi = fantomConfig.getValue('openapi').toString();
    late String path;
    String? downloadPath =
        fantomConfig.getValue(GenerateCommand.optionDownloadPath);
    if (openapi.isValidUrl) {
      final url = openapi;
      final downloader = FileDownloader(fileUrl: url, savePath: downloadPath);
      final openapiFile = await downloader.download();
      path = openapiFile.path;
      Log.debug(path);
      Log.debug(openapiFile.lengthSync());
    } else {
      path = openapi;
    }
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
    checkExcludedComponentsValues(excludedComponentNames);
    List<String> excludedPathsNames =
        ((fantomConfig.getValue('excluded-paths') as List?) ?? [])
            .map((e) => e.toString())
            .toList();

    final excludedPaths =
        ExcludedPaths.fromFantomConfigValues(excludedPathsNames);

    return FantomConfig(
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
