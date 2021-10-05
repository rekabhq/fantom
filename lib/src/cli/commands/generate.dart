import 'dart:async';

import 'package:args/args.dart';
import 'package:fantom/src/cli/commands/base_command.dart';
import 'package:fantom/src/extensions/extensions.dart';
import 'package:fantom/src/utils/logger.dart';
import 'package:fantom/src/utils/process_manager.dart';

class GenerateCommand extends BaseCommand<GenerateCommandArguments> {
  GenerateCommand()
      : super(
          name: 'generate',
          description: 'generates network client module from openapi document',
        );

  @override
  void defineCliOptions(ArgParser argParser) {
    argParser.addOption('config', abbr: 'c', help: 'gathers all the argument for generate command from a yaml file');
  }

  @override
  FutureOr<GenerateCommandArguments> createArgumnets(ArgResults argResults) {
    //TODO - this should be overriden to return arguments from argResults
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
    Log.spacer();
    await runFromCmd('java', args: ['--version']);
    await 0.3.secondsDelay();
    Log.spacer();
    await runFromCmd('flutter', args: ['--version']);
    Log.spacer();
    var progress = Log.progress('⚙️ ⚙️ ⚙️  generating module files');
    await 4.secondsDelay();
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
  final String outputModelsPath;
  final String outputApisPath;

  GenerateCommandArguments({
    required this.inputOpenapiFilePath,
    required this.outputModulePath,
    required this.outputModelsPath,
    required this.outputApisPath,
  });
}
