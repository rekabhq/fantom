import 'package:args/command_runner.dart';
import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/cli/commands/validate.dart';
import 'package:fantom/src/utils/constants.dart';
import 'package:fantom/src/utils/logger.dart';
import 'package:fantom/src/utils/update_checker.dart';
import 'package:io/io.dart';

class FantomCli extends CommandRunner<int> {
  FantomCli() : super(kCliName, 'OpenApi Network Client Generator and much more') {
    addCommand(ValidateCommand());
    addCommand(GenerateCommand());
  }

  @override
  Future<int> run(Iterable<String> args) async {
    await _checkIfNewVersionOfThisLibraryIsAvailable();
    final argResults = parse(args);
    await runCommand(argResults);
    if (ConsoleController.isCli) {
      await sharedStdIn.terminate();
    }
    // TODO - we should return the correct exit code here
    return ExitCode.success.code;
  }

  Future _checkIfNewVersionOfThisLibraryIsAvailable() async {
    await UpdateChecker(packageName: 'fvm', currentVersion: kCurrentVersion)
        .update()
        .onError((error, stackTrace) => Log.debug('could not check for package new version'))
        .timeout(const Duration(seconds: 4), onTimeout: () {/* do nothing */});
  }
}
