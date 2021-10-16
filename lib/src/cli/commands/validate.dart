import 'dart:async';

import 'package:args/args.dart';
import 'package:fantom/src/cli/commands/base_command.dart';
import 'package:fantom/src/extensions/extensions.dart';
import 'package:fantom/src/utils/logger.dart';

/// this command validates whether the openapi specification file provided is valid or not

class ValidateCommand extends BaseCommand<ValidateCommandArgs> {
  ValidateCommand()
      : super(
          name: 'validate',
          description: 'checks if the openapi document is valid ',
        );

  @override
  void defineCliOptions(ArgParser argParser) {
    //TODO - define options needed
  }

  @override
  FutureOr<ValidateCommandArgs> createArguments(ArgResults argResults) {
    return ValidateCommandArgs();
  }

  @override
  FutureOr<int> runCommand(ValidateCommandArgs arguments) async {
    // TODO implement this class to validate the openapi file
    Log.info('reading open api file');
    await 1.secondsDelay();
    Log.fine('file is valid');
    // TODO - we should return the correct exit code here
    return 0;
  }
}

class ValidateCommandArgs {}
