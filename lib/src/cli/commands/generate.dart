import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:fantom/src/cli/commands/base_command.dart';
import 'package:fantom/src/cli/fantom_config.dart';
import 'package:fantom/src/exceptions/exceptions.dart';
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
/// generate --path path/to/openapi --output path/to/module/output
///
/// generate --path path/to/openapi --models-output path/output/models --apis-output path/output/apis
///
/// generate -c fantom.yaml
///
/// generate -c some-config.yaml
///
/// **NOTE**: note that config file must be either in json or yaml format and the config should be something like example
/// below:
///
/// ```yaml
///  fantom:
///    path: path/to/openapi.yaml
///    output: path/to/module
///    models-output: path/to/models/output/dir
///    apis-output: path/to/apis/output/dir
///```
///
class GenerateCommand extends BaseCommand<GenerateConfig> {
  GenerateCommand({
    required this.currentDirectory,
    required this.defaultModelsOutputPath,
    required this.defaultApisOutputPath,
  }) : super(name: 'generate', description: 'generates network client module from openapi document');

  final Directory currentDirectory;
  final String defaultModelsOutputPath;
  final String defaultApisOutputPath;

  static const String optionConfig = 'config';
  static const String optionOutput = 'output';
  static const String optionModelsOutput = 'models-output';
  static const String optionApisOutput = 'apis-output';

  static GenerateCommand createDefaultInstance() => GenerateCommand(
        currentDirectory: kCurrentDirectory,
        defaultModelsOutputPath: kDefaultModelsOutputPath,
        defaultApisOutputPath: kDefaultApisOutputPath,
      );

  @override
  void defineCliOptions(ArgParser argParser) {
    argParser.addOption(optionOutput, abbr: 'o', help: 'path where network module should be generated in');
    argParser.addOption(optionModelsOutput, abbr: 'm', help: 'path where generated models will be stored in');
    argParser.addOption(optionApisOutput, abbr: 'a', help: 'path where generated apis will be stored in');
  }

  @override
  FutureOr<GenerateConfig> createArguments(ArgResults argResults) async {
    Log.debug(argResults.arguments);
    Log.debug(argResults.command);
    Log.debug(argResults.name);
    Log.debug(argResults.options);
    Log.debug(argResults.rest);

    // if user entered a path to a file like openapi.yaml or openapi.json or fantom.yaml etc
    var userEnteredAPathToAFile = argResults.rest.isNotEmpty;

    if (userEnteredAPathToAFile) {
      var openapiOrFantomConfigFile = argResults.rest[0];
      var fantomConfig = await FantomConfig.fromArgResults(openapiOrFantomConfigFile, argResults);
      var openApiMap = await getFileInPath(
        path: fantomConfig.path,
        notFoundErrorMessage: 'openapi file (path | p) is either not provided or invalid',
      ).then((file) => readJsonOrYamlFile(file));
      if (fantomConfig.outputModelsPath == null &&
          fantomConfig.outputApisPath == null &&
          fantomConfig.outputModulePath == null) {
        return _createDefaultGenerateArgs(openApiMap);
      }
      // check if user wants to generate module as part of the project where models and apis are in separate folders
      else if (fantomConfig.outputModelsPath != null && fantomConfig.outputApisPath != null) {
        return _createGenerateAsPartOfProjectArgs(
          openApiMap,
          fantomConfig.outputModelsPath!,
          fantomConfig.outputApisPath!,
        );
      } else {
        _warnUser(fantomConfig.outputModelsPath, fantomConfig.outputApisPath);
        return _createGenerateAsStandAlonePackageArgs(openApiMap, fantomConfig.outputModulePath);
      }
    } else {
      return tryToCreateGenerateArgsWithoutAnyCliInput();
    }
  }

  @override
  FutureOr<int> runCommand(GenerateConfig arguments) async {
    if (arguments is GenerateAsStandAlonePackageConfig) {
      Log.debug(arguments);
      // TODO generate client as a standalone module and return the correct exit code
    } else if (arguments is GenerateAsPartOfProjectConfig) {
      // TODO generate client not as a module but part of the project with models and apis in separate packages
      // TODO and return the correct exit code
      Log.debug(arguments);
    } else {
      throw Exception(
        'Unknown arguments type for generate command'
        'if you\'re seeing this message please open an issue',
      );
    }
    return 0;
  }

  /// tries to read the user defined configuration for how to generate the fantom network client and
  /// returns a [GenerateConfig] based on user's configuration.
  ///
  /// if file in [configFilePath] does not contain a fantom configuration [GenerationConfigNotProvidedException] will be thrown
  ///
  /// **NOTE**: note that config file must be either in json or yaml format and the config should be something like example
  /// below:
  ///
  /// ```yaml
  ///  fantom:
  ///    path: path/to/openapi.yaml
  ///    output: path/to/module
  ///    models-output: path/to/models/output/dir
  ///    apis-output: path/to/apis/output/dir
  ///```
  Future<GenerateConfig> _getGenerateArgsFromFantomConfig(String configFilePath) async {
    var file = await getFileInPath(
      path: configFilePath,
      notFoundErrorMessage: '(config | c) file path is invalid',
    );
    var fantomConfig = await FantomConfig.fromFile(file);
    var openApiMap = await getFileInPath(
      path: fantomConfig.path,
      notFoundErrorMessage: 'openapi file (path | p) is either not provided or invalid',
    ).then((file) => readJsonOrYamlFile(file));
    if (fantomConfig.outputModelsPath != null && fantomConfig.outputApisPath != null) {
      // at this point we don't want to create network client as a module since models and apis path are separate
      return _createGenerateAsPartOfProjectArgs(
        openApiMap,
        fantomConfig.outputModelsPath!,
        fantomConfig.outputApisPath!,
      );
    } else {
      _warnUser(fantomConfig.outputModelsPath, fantomConfig.outputApisPath);
      return _createGenerateAsStandAlonePackageArgs(openApiMap, fantomConfig.outputModulePath);
    }
  }

  /// tries to creates a [GenerateAsPartOfProjectConfig] from the given arguments
  Future<GenerateAsPartOfProjectConfig> _createGenerateAsPartOfProjectArgs(
    Map<String, dynamic> openApiMap,
    String outputModelsPath,
    String outputApisPath,
  ) async {
    var modelsDirectory = await getDirectoryInPath(
      path: outputModelsPath,
      directoryPathIsNotValid: '(models-output | m) directory path is not valid',
    );

    var apisDirectory = await getDirectoryInPath(
      path: outputApisPath,
      directoryPathIsNotValid: '(apis-output | a) directory path is not valid',
    );

    return GenerateAsPartOfProjectConfig(
      openApi: openApiMap,
      outputModelsDir: modelsDirectory,
      outputApisDir: apisDirectory,
    );
  }

  /// tries to creates a [GenerateAsStandAlonePackageConfig] from the given arguments
  FutureOr<GenerateAsStandAlonePackageConfig> _createGenerateAsStandAlonePackageArgs(
    Map<String, dynamic> openApiMap,
    String? outputModulePath,
  ) async {
    // warning user
    var outputModuleDirectory = await getDirectoryInPath(
      path: outputModulePath,
      directoryPathIsNotValid: '(output | o) module directory path is not provided or not valid',
    );
    return GenerateAsStandAlonePackageConfig(
      openApi: openApiMap,
      outputModuleDir: outputModuleDirectory,
    );
  }

  /// checks if either both paths are null or both are not null and if not it will log a warning to the user
  /// about the usercase of (models-output | m) cli option and (apis-output | a) cli option since if one of these
  /// cli options is provided the other one is needed as well
  void _warnUser(String? outputModelsPath, String? outputApisPath) {
    if (outputModelsPath == null && outputApisPath == null) {
      return;
    }
    if (outputModelsPath != null && outputApisPath != null) {
      return;
    }
    if (outputModelsPath != null || outputApisPath != null) {
      Log.divider();
      Log.warning(
        'If you want to generate models and api in separate directories in your project instead '
        'of generating the whole fantom client in a module you must provide both (models-output | m) and (apis-output | a) '
        'arguments, if not fantom client will be generated in a module if (output | o) argument is provided',
      );
      Log.divider();
    }
  }

  /// will try to find a fantom config in `pubspec.yaml` or `fantom.yaml` if said files exist in current directory
  /// where the generate command is ran
  ///
  ///
  /// this is useful for when when user has provided no options or config file when running the generate command
  /// or in other words if user ran the following command from the command line without providing any options
  ///
  /// `$ fantom generate`
  Future<GenerateConfig> tryToCreateGenerateArgsWithoutAnyCliInput() async {
    var children = currentDirectory.listSync();
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
      return _getGenerateArgsFromFantomConfig(fantomFile.path);
    } else if (pubspecFile != null) {
      return _getGenerateArgsFromFantomConfig(pubspecFile.path);
    } else {
      throw GenerationConfigNotProvidedException();
    }
  }

  Future<GenerateAsPartOfProjectConfig> _createDefaultGenerateArgs(Map<String, dynamic> openApiMap) async {
    if (currentDirectory.isDartOrFlutterProject) {
      var outputModelsPath = await getDirectoryInPath(
        path: defaultModelsOutputPath,
        directoryPathIsNotValid: 'default directory path for models is not valid',
      );

      var outputApisPath = await getDirectoryInPath(
        path: defaultApisOutputPath,
        directoryPathIsNotValid: 'default directory path for apis is not valid',
      );

      return GenerateAsPartOfProjectConfig(
        openApi: openApiMap,
        outputModelsDir: outputModelsPath,
        outputApisDir: outputApisPath,
      );
    } else {
      throw GenerationConfigNotProvidedException();
    }
  }
}

class GenerateConfig {}

/// this argument is used by generate command to generate the fantom client as a standalone module
class GenerateAsStandAlonePackageConfig extends GenerateConfig {
  final Map<String, dynamic> openApi;
  final Directory outputModuleDir;

  GenerateAsStandAlonePackageConfig({
    required this.openApi,
    required this.outputModuleDir,
  });

  @override
  String toString() {
    var map = {
      'openapi': openApi['info'].toString(),
      GenerateCommand.optionOutput: outputModuleDir.toString(),
    };
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(map);
  }
}

/// this argument is used by generate command to generate the fantom client as part of the user's project
/// where models and apis can be generated in different directories.
class GenerateAsPartOfProjectConfig extends GenerateConfig {
  final Map<String, dynamic> openApi;
  final Directory outputModelsDir;
  final Directory outputApisDir;

  GenerateAsPartOfProjectConfig({
    required this.openApi,
    required this.outputModelsDir,
    required this.outputApisDir,
  });

  @override
  String toString() {
    var map = {
      'openapi': openApi['info'].toString(),
      GenerateCommand.optionModelsOutput: outputModelsDir.toString(),
      GenerateCommand.optionApisOutput: outputApisDir.toString(),
    };
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(map);
  }
}
