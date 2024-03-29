import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:fantom/src/cli/commands/base_command.dart';
import 'package:fantom/src/cli/config/fantom_config.dart';
import 'package:fantom/src/cli/options_values.dart';
import 'package:fantom/src/utils/exceptions.dart';
import 'package:fantom/src/utils/extensions.dart';
import 'package:fantom/src/generator/generator.dart';
import 'package:fantom/src/reader/openapi_reader.dart';
import 'package:fantom/src/utils/constants.dart';
import 'package:fantom/src/utils/logger.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:fantom/src/writer/file_writer.dart';

/// generates network client module from openapi document
///
/// **NOTE**: note that config file must be either in json or yaml format and the config should be something like example
/// below:
///
/// ```yaml
///  fantom:
///    openapi: path/to/openapi.yaml
///    package: path/to/module
///    package-name: app_api
///    model-dir: path/to/models/output/dir
///    api-dir: path/to/apis/output/dir
///```
///
class GenerateCommand extends BaseCommand<GenerateConfig> {
  GenerateCommand({
    required this.currentDirectory,
    required this.defaultModelsOutputPath,
    required this.defaultApisOutputPath,
  }) : super(
          name: 'generate',
          description: 'generates network client module from openapi document',
        );

  final Directory currentDirectory;
  final String defaultModelsOutputPath;
  final String defaultApisOutputPath;

  static const String optionDir = 'dir';
  static const String optionPackage = 'package';
  static const String optionPackageName = 'package-name';
  static const String optionRecreatePackage = 'recreate-package';
  static const String optionModelDir = 'model-dir';
  static const String optionApiDir = 'api-dir';
  static const String optionMethodRetuenType = 'method-return-type';
  static const String optionDownloadPath = 'download-path';

  static const String abbrDir = 'd';
  static const String abbrPackage = 'p';
  static const String abbrPackageName = 'n';
  static const String abbrRecreatePackage = 'R';
  static const String abbrModelsDir = 'm';
  static const String abbrApiDir = 'a';
  static const String abbrMethodReturnType = 'r';
  static const String abbrDownloadPath = 'e';

  static GenerateCommand createDefaultInstance() => GenerateCommand(
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
      help: 'path where network package should be generated in',
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
    argParser.addOption(
      optionPackageName,
      abbr: abbrPackageName,
      help: 'name you want for your generated network package and api-class',
    );
    argParser.addOption(
      optionRecreatePackage,
      abbr: abbrRecreatePackage,
      help:
          'if set to false package will not be created each time files are generated. default = true',
      // defaultsTo: 'false', // does not work for boolean values
    );
    argParser.addOption(
      optionMethodRetuenType,
      abbr: abbrMethodReturnType,
      help: 'return type of the api methods',
      defaultsTo: MethodReturnType.result,
      allowed: [MethodReturnType.simple, MethodReturnType.result],
      allowedHelp: {
        MethodReturnType.result:
            'return type of api methods will be a Future<Result<DATA,ERROR>>',
        MethodReturnType.simple:
            'return type of api methods will be Future<DATA>',
      },
    );
    argParser.addOption(
      optionDownloadPath,
      abbr: abbrDownloadPath,
      help: 'where download openapi file will be saved. only works when '
          'instead of a local path to openapi file a url is provided',
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
        return _createDefaultGenerateArgs(openApiMap, fantomConfig);
      }
      // check if user wants to generate module as part of the project where models and apis are in separate folders
      else if (fantomConfig.outputModelsDir != null &&
          fantomConfig.outputApiDir != null) {
        return _createGenerateAsPartOfProjectArgs(openApiMap, fantomConfig);
      } else if (fantomConfig.outputDir != null) {
        return _createGenerateAsPartOfProjectArgsWithOutputDir(
            openApiMap, fantomConfig);
      } else {
        _warnUser(fantomConfig.outputModelsDir, fantomConfig.outputApiDir);
        return _createGenerateAsStandAlonePackageArgs(openApiMap, fantomConfig);
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
    var openapiModel = OpenApiReader(
      openapi: arguments.openApi,
      config: arguments.fantomConfig,
    ).parseOpenApiModel();
    progress.finish(showTiming: true);
    // generate models and apis
    progress = Log.progress('🔥 Generating ... ');
    var generationData =
        Generator.createDefault(openapiModel, arguments).generate();
    progress.finish(showTiming: true);
    // write files
    Log.info('✍  Writing Generated Files');
    Log.divider();
    Log.spacer();
    await FileWriter(generationData).writeGeneratedFiles();
    Log.fine('👻 ALL GOOD 👻');
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
      return _createGenerateAsPartOfProjectArgs(openApiMap, fantomConfig);
    } else {
      _warnUser(fantomConfig.outputModelsDir, fantomConfig.outputApiDir);
      return _createGenerateAsStandAlonePackageArgs(openApiMap, fantomConfig);
    }
  }

  /// tries to creates a [GenerateAsPartOfProjectConfig] from the given arguments
  Future<GenerateAsPartOfProjectConfig> _createGenerateAsPartOfProjectArgs(
    Map<String, dynamic> openApiMap,
    FantomConfig fantomConfig,
  ) async {
    var modelsDirectory = await getDirectoryInPath(
      path: fantomConfig.outputModelsDir,
      directoryPathIsNotValid:
          '($optionModelDir | $abbrModelsDir) directory path is not valid',
    );

    var apisDirectory = await getDirectoryInPath(
      path: fantomConfig.outputApiDir,
      directoryPathIsNotValid:
          '($optionApiDir | $abbrApiDir) directory path is not valid',
    );

    return GenerateAsPartOfProjectConfig(
      openApi: openApiMap,
      outputModelsDir: modelsDirectory,
      outputApisDir: apisDirectory,
      fantomConfig: fantomConfig,
    );
  }

  /// tries to creates a [GenerateAsPartOfProjectConfig] from the given arguments
  Future<GenerateAsPartOfProjectConfig>
      _createGenerateAsPartOfProjectArgsWithOutputDir(
    Map<String, dynamic> openApiMap,
    FantomConfig fantomConfig,
  ) async {
    var directory = await getDirectoryInPath(
      path: fantomConfig.outputDir,
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
      fantomConfig: fantomConfig,
    );
  }

  /// tries to creates a [GenerateAsStandAlonePackageConfig] from the given arguments
  FutureOr<GenerateAsStandAlonePackageConfig>
      _createGenerateAsStandAlonePackageArgs(
    Map<String, dynamic> openApiMap,
    FantomConfig fantomConfig,
  ) async {
    var outputModuleDirectory = await getDirectoryInPath(
      path: fantomConfig.outputPackageDir,
      directoryPathIsNotValid:
          '($optionPackage | $abbrPackage) module directory path is not provided or not valid',
    );

    return GenerateAsStandAlonePackageConfig(
      openApi: openApiMap,
      packageName: fantomConfig.packageName ?? kDefaultGeneratedPackageName,
      outputModuleDir: outputModuleDirectory,
      fantomConfig: fantomConfig,
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
    Map<String, dynamic> openApiMap,
    FantomConfig fantomConfig,
  ) async {
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
        fantomConfig: fantomConfig,
      );
    } else {
      throw GenerationConfigNotProvidedException();
    }
  }
}

class GenerateConfig {
  final Map<String, dynamic> openApi;
  final FantomConfig fantomConfig;
  GenerateConfig({
    required this.openApi,
    required this.fantomConfig,
  });
}

/// this argument is used by generate command to generate the fantom client as a standalone module
class GenerateAsStandAlonePackageConfig extends GenerateConfig {
  final Directory outputModuleDir;
  final String packageName;

  GenerateAsStandAlonePackageConfig({
    required Map<String, dynamic> openApi,
    required FantomConfig fantomConfig,
    required this.packageName,
    required this.outputModuleDir,
  }) : super(
          openApi: openApi,
          fantomConfig: fantomConfig,
        );

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
    required FantomConfig fantomConfig,
    required this.outputModelsDir,
    required this.outputApisDir,
  }) : super(
          openApi: openApi,
          fantomConfig: fantomConfig,
        );

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
