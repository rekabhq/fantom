import 'package:args/command_runner.dart';
import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/cli/commands/validate.dart';
import 'package:fantom/src/utils/constants.dart';
import 'package:fantom/src/utils/logger.dart';
import 'package:io/io.dart';

class FantomCli extends CommandRunner<int> {
  FantomCli() : super(kCliName, 'OpenApi Network Client Generator and much more') {
    addCommand(ValidateCommand());
    addCommand(GenerateCommand());
  }

  @override
  Future<int> run(Iterable<String> args) async {
    final argResults = parse(args);
    await runCommand(argResults);
    if (ConsoleController.isCli) {
      await sharedStdIn.terminate();
    }
    // TODO - we should return the correct exit code here
    return ExitCode.success.code;
  }
}
