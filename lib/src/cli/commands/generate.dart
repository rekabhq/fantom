import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:fantom/src/cli/commands/base_command.dart';
import 'package:fantom/src/cli/fantom_config.dart';
import 'package:fantom/src/exceptions/exceptions.dart';
import 'package:fantom/src/extensions/extensions.dart';
import 'package:fantom/src/openapi/reader/openapi_reader.dart';
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
    required this.openApiReader,
    required this.currentDirectory,
    required this.defaultModelsOutputPath,
    required this.defaultApisOutputPath,
  }) : super(
            name: 'generate',
            description:
                'generates network client module from openapi document');

  final Directory currentDirectory;
  final String defaultModelsOutputPath;
  final String defaultApisOutputPath;
  final OpenApiReader openApiReader;

  static const String optionDir = 'dir';
  static const String optionPackage = 'package';
  static const String optionModelDir = 'model-dir';
  static const String optionApiDir = 'api-dir';

  static const String abbrDir = 'd';
  static const String abbrPackage = 'p';
  static const String abbrModelsDir = 'm';
  static const String abbrApiDir = 'a';

  static GenerateCommand createDefaultInstance() => GenerateCommand(
        openApiReader: OpenApiReader(),
        currentDirectory: kCurrentDirectory,
        defaultModelsOutputPath: kDefaultModelsOutputPath,
        defaultApisOutputPath: kDefaultApisOutputPath,
      );

  @override
  void defineCliOptions(ArgParser argParser) {
    argParser.addOption(
      optionDir,
      abbr: abbrDir,
      help: 'path where generated files will be stored in',
    );
    argParser.addOption(
      optionPackage,
      abbr: abbrPackage,
      help: 'path where network module should be generated in',
    );
    argParser.addOption(
      optionModelDir,
      abbr: abbrModelsDir,
      help: 'path where generated models will be stored in',
    );
    argParser.addOption(
      optionApiDir,
      abbr: abbrApiDir,
      help: 'path where generated apis will be stored in',
    );
  }

  @override
  FutureOr<GenerateConfig> createArguments(ArgResults argResults) async {
    // if user entered a path to a file like openapi.yaml or openapi.json or fantom.yaml etc
    var userEnteredAPathToAFile = argResults.rest.isNotEmpty;

    if (userEnteredAPathToAFile) {
      var openapiOrFantomConfigFile = argResults.rest[0];
      var fantomConfig = await FantomConfig.fromArgResults(
          openapiOrFantomConfigFile, argResults);
      var openApiMap = await getFileInPath(
        path: fantomConfig.path,
        notFoundErrorMessage:
            'openapi file path is either not provided or invalid',
      ).then((file) => readJsonOrYamlFile(file));
      if (fantomConfig.outputModelsDir == null &&
          fantomConfig.outputDir == null &&
          fantomConfig.outputApiDir == null &&
          fantomConfig.outputPackageDir == null) {
        return _createDefaultGenerateArgs(openApiMap);
      }
      // check if user wants to generate module as part of the project where models and apis are in separate folders
      else if (fantomConfig.outputModelsDir != null &&
          fantomConfig.outputApiDir != null) {
        return _createGenerateAsPartOfProjectArgs(
          openApiMap,
          fantomConfig.outputModelsDir!,
          fantomConfig.outputApiDir!,
        );
      } else if (fantomConfig.outputDir != null) {
        return _createGenerateAsPartOfProjectArgsWithOutputDir(
            openApiMap, fantomConfig.outputDir!);
      } else {
        _warnUser(fantomConfig.outputModelsDir, fantomConfig.outputApiDir);
        return _createGenerateAsStandAlonePackageArgs(
            openApiMap, fantomConfig.outputPackageDir);
      }
    } else {
      return tryToCreateGenerateArgsWithoutAnyCliInput();
    }
  }

  @override
  FutureOr<int> runCommand(GenerateConfig arguments) async {
    // parse an OpenApi model object from openapi map in arguments
    var progress = Log.progress('🤓 Reading openapi file');
    // ignore: unused_local_variable
    var openapiModel = openApiReader.parseOpenApiModel(arguments.openApi);
    progress.finish(showTiming: true);
    // generate models and apis
    // TODO: generate models and apis
    // write files
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
  ///```yaml
  ///  fantom:
  ///    path: path/to/openapi.yaml
  ///    output: path/to/module
  ///    models-output: path/to/models/output/dir
  ///    apis-output: path/to/apis/output/dir
  ///```
  Future<GenerateConfig> _getGenerateArgsFromFantomConfig(
    String configFilePath,
  ) async {
    var file = await getFileInPath(
      path: configFilePath,
      notFoundErrorMessage:
          'file path for config file is not valid $configFilePath',
    );
    var fantomConfig = await FantomConfig.fromFile(file);
    var openApiMap = await getFileInPath(
      path: fantomConfig.path,
      notFoundErrorMessage:
          'openapi file path is either not provided or invalid in the config provided in file $configFilePath',
    ).then((file) => readJsonOrYamlFile(file));
    if (fantomConfig.outputModelsDir != null &&
        fantomConfig.outputApiDir != null) {
      // at this point we don't want to create network client as a module since models and apis path are separate
      return _createGenerateAsPartOfProjectArgs(
        openApiMap,
        fantomConfig.outputModelsDir!,
        fantomConfig.outputApiDir!,
      );
    } else {
      _warnUser(fantomConfig.outputModelsDir, fantomConfig.outputApiDir);
      return _createGenerateAsStandAlonePackageArgs(
          openApiMap, fantomConfig.outputPackageDir);
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
      directoryPathIsNotValid:
          '($optionModelDir | $abbrModelsDir) directory path is not valid',
    );

    var apisDirectory = await getDirectoryInPath(
      path: outputApisPath,
      directoryPathIsNotValid:
          '($optionApiDir | $abbrApiDir) directory path is not valid',
    );

    return GenerateAsPartOfProjectConfig(
      openApi: openApiMap,
      outputModelsDir: modelsDirectory,
      outputApisDir: apisDirectory,
    );
  }

  /// tries to creates a [GenerateAsPartOfProjectConfig] from the given arguments
  Future<GenerateAsPartOfProjectConfig>
      _createGenerateAsPartOfProjectArgsWithOutputDir(
    Map<String, dynamic> openApiMap,
    String outputDirPath,
  ) async {
    var directory = await getDirectoryInPath(
      path: outputDirPath,
      directoryPathIsNotValid:
          '($optionDir | $abbrDir) directory path is not valid',
    );
    var modelsDirectory = await getDirectoryInPath(
      path: '${directory.path}/model',
      directoryPathIsNotValid:
          '($optionDir | $abbrDir) directory path is not valid',
    );

    var apisDirectory = await getDirectoryInPath(
      path: '${directory.path}/api',
      directoryPathIsNotValid:
          '($optionDir | $abbrDir) directory path is not valid',
    );

    return GenerateAsPartOfProjectConfig(
      openApi: openApiMap,
      outputModelsDir: modelsDirectory,
      outputApisDir: apisDirectory,
    );
  }

  /// tries to creates a [GenerateAsStandAlonePackageConfig] from the given arguments
  FutureOr<GenerateAsStandAlonePackageConfig>
      _createGenerateAsStandAlonePackageArgs(
    Map<String, dynamic> openApiMap,
    String? outputModulePath,
  ) async {
    // warning user
    var outputModuleDirectory = await getDirectoryInPath(
      path: outputModulePath,
      directoryPathIsNotValid:
          '($optionPackage | $abbrPackage) module directory path is not provided or not valid',
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
        'of generating the whole fantom client in a module you must provide both ($optionModelDir | $abbrModelsDir) and ($optionApiDir | $abbrApiDir) '
        'arguments, if not fantom client will be generated in a module if ($optionPackage | $abbrPackage) argument is provided',
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

  Future<GenerateAsPartOfProjectConfig> _createDefaultGenerateArgs(
      Map<String, dynamic> openApiMap) async {
    if (currentDirectory.isDartOrFlutterProject) {
      var outputModelsPath = await getDirectoryInPath(
        path: defaultModelsOutputPath,
        directoryPathIsNotValid:
            'default directory path for models is not valid $defaultModelsOutputPath',
      );

      var outputApisPath = await getDirectoryInPath(
        path: defaultApisOutputPath,
        directoryPathIsNotValid:
            'default directory path for apis is not valid $defaultApisOutputPath',
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

class GenerateConfig {
  final Map<String, dynamic> openApi;
  GenerateConfig({required this.openApi});
}

/// this argument is used by generate command to generate the fantom client as a standalone module
class GenerateAsStandAlonePackageConfig extends GenerateConfig {
  final Directory outputModuleDir;

  GenerateAsStandAlonePackageConfig({
    required Map<String, dynamic> openApi,
    required this.outputModuleDir,
  }) : super(openApi: openApi);

  @override
  String toString() {
    var map = {
      'openapi': openApi['info'].toString(),
      GenerateCommand.optionPackage: outputModuleDir.toString(),
    };
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(map);
  }
}

/// this argument is used by generate command to generate the fantom client as part of the user's project
/// where models and apis can be generated in different directories.
class GenerateAsPartOfProjectConfig extends GenerateConfig {
  final Directory outputModelsDir;
  final Directory outputApisDir;

  GenerateAsPartOfProjectConfig({
    required Map<String, dynamic> openApi,
    required this.outputModelsDir,
    required this.outputApisDir,
  }) : super(openApi: openApi);

  @override
  String toString() {
    var map = {
      'openapi': openApi['info'].toString(),
      GenerateCommand.optionModelDir: outputModelsDir.toString(),
      GenerateCommand.optionApiDir: outputApisDir.toString(),
    };
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(map);
  }
}
