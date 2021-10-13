import 'dart:io';

import 'package:args/args.dart';
import 'package:fantom/src/exceptions/exceptions.dart';
import 'package:fantom/src/extensions/extensions.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:io/io.dart';

class FantomConfig {
  FantomConfig._({
    required this.path,
    this.outputModulePath,
    this.outputModelsPath,
    this.outputApisPath,
  });

  final String path;
  final String? outputModulePath;
  final String? outputModelsPath;
  final String? outputApisPath;

  static FantomConfig fromArgResults(ArgResults argResults) {
    String? inputOpenApiFilePath;
    String? outputModulePath;
    String? outputModelsPath;
    String? outputApisPath;
    // getting cli options user entered
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
    return FantomConfig._(
      path: inputOpenApiFilePath!,
      outputModulePath: outputModulePath,
      outputModelsPath: outputModelsPath,
      outputApisPath: outputApisPath,
    );
  }

  static Future<FantomConfig> fromFile(File file) async {
    var json = await readJsonOrYamlFile(file);
    if (!json.containsKey('fantom')) {
      throw NoFantomConfigFound(file.path);
    }
    Map fantomConfig = json['fantom'];
    if (!fantomConfig.containsKey('path')) {
      throw FantomException(
        '(path) to openapi file is not provided in fantom config file',
        ExitCode.noInput.code,
      );
    }
    var path = fantomConfig.getValue('path');
    String? outputModulePath = fantomConfig.getValue('output');
    String? outputModelsPath = fantomConfig.getValue('models-output');
    String? outputApisPath = fantomConfig.getValue('apis-output');
    return FantomConfig._(
      path: path,
      outputModulePath: outputModulePath,
      outputModelsPath: outputModelsPath,
      outputApisPath: outputApisPath,
    );
  }
}
