import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:fantom/src/cli/commands/base_command.dart';
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
  FutureOr<GenerateConfig> createArguments(ArgResults argResults) async {
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
      var openApiMap = await getFileInPath(
        path: inputOpenApiFilePath,
        notFoundErrorMessage: 'openapi file (path | p) is either not provided or invalid',
      ).then((file) => readJsonOrYamlFile(file));
      if (outputModelsPath == null && outputApisPath == null && outputModulePath == null && fantomConfigPath == null) {
        return _createDefaultGenerateArgs(openApiMap);
      }
      // check if user wants to generate module as part of the project where models and apis are in separate folders
      else if (outputModelsPath != null && outputApisPath != null) {
        return _createGenerateAsPartOfProjectArgs(openApiMap, outputModelsPath, outputApisPath);
      } else {
        _warnUser(outputModelsPath, outputApisPath);
        return _createGenerateAsStandAlonePackageArgs(openApiMap, outputModulePath);
      }
    } else if (fantomConfigPath.isNotNullOrBlank) {
      return _getGenerateArgsFromFantomConfig(fantomConfigPath!);
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
    var config = await readJsonOrYamlFile(file);
    if (!config.containsKey('fantom')) {
      throw NoFantomConfigFound(configFilePath);
    }
    Map fantomConfig = config['fantom'];
    var path = fantomConfig.getValue('path');
    String? outputModulePath = fantomConfig.getValue('output');
    String? outputModelsPath = fantomConfig.getValue('models-output');
    String? outputApisPath = fantomConfig.getValue('apis-output');
    var openApiMap = await getFileInPath(
      path: path,
      notFoundErrorMessage: 'openapi file (path | p) is either not provided or invalid',
    ).then((file) => readJsonOrYamlFile(file));
    if (outputModelsPath != null && outputApisPath != null) {
      // at this point we don't want to create network client as a module since models and apis path are separate
      return _createGenerateAsPartOfProjectArgs(openApiMap, outputModelsPath, outputApisPath);
    } else {
      _warnUser(outputModelsPath, outputApisPath);
      return _createGenerateAsStandAlonePackageArgs(openApiMap, outputModulePath);
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
    var children = kCurrentDirectory.listSync();
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
    if (kCurrentDirectory.isDartOrFlutterProject) {
      var outputModelsPath = await getDirectoryInPath(
        path: kDefaultModelsOutputPath,
        directoryPathIsNotValid: 'default directory path for models is not valid',
      );

      var outputApisPath = await getDirectoryInPath(
        path: kDefaultApisOutputPath,
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
    var map = {'openapi': openApi, 'output': outputModuleDir};
    return map.toString();
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
    var map = {'openapi': openApi, 'models-output': outputModelsDir, 'apis-output': outputApisDir};
    return map.toString();
  }
}
