import 'dart:async';

import 'package:args/args.dart';
import 'package:fantom/src/cli/commands/base_command.dart';
import 'package:fantom/src/extensions/extensions.dart';
import 'package:fantom/src/utils/logger.dart';
import 'package:fantom/src/utils/process_manager.dart';

class GenerateCommand extends BaseCommand<GenerateCommandArguments> {
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
  FutureOr<GenerateCommandArguments> createArgumnets(ArgResults argResults) {
    Log.debug(argResults.arguments.toString());
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
    Log.debug(fantomConfigPath ?? '');
    Log.debug(inputOpenApiFilePath ?? '');
    Log.debug(outputModulePath ?? '');
    Log.debug(outputModelsPath ?? '');
    Log.debug(outputApisPath ?? '');
    return GenerateCommandArguments(
      inputOpenapiFilePath: 'fake/path/to/file',
      outputModulePath: 'fake/path/to/modulePath',
      outputModelsPath: 'fake/path/to/modelsPath',
      outputApisPath: 'fake/path/to/apisPath',
    );
  }

  @override
  FutureOr<int> runCommand(GenerateCommandArguments arguments) async {
    Log.info('📚 Reading openapi document from path');
    Log.fine('this line should be green');
    Log.spacer();
    await runFromCmd('java', args: ['--version']);
    await 0.3.secondsDelay();
    Log.spacer();
    await runFromCmd('flutter', args: ['--version']);
    Log.spacer();
    var progress = Log.progress('⚙️ ⚙️ ⚙️  generating module files');
    await 2.secondsDelay();
    progress.finish(showTiming: true);
    Log.divider();
    Log.fine('🦄 module generated successfuly, you\'re good to go');
    // TODO - we should return the correct exit code here
    return 0;
  }
}

class GenerateCommandArguments {
  final String inputOpenapiFilePath;
  final String outputModulePath;
  final String? outputModelsPath;
  final String? outputApisPath;

  GenerateCommandArguments({
    required this.inputOpenapiFilePath,
    required this.outputModulePath,
    this.outputModelsPath,
    this.outputApisPath,
  });
}
