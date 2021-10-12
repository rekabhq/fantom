import 'package:args/command_runner.dart';
import 'package:fantom/fantom.dart';
import 'package:fantom/src/cli/commands/base_command.dart';
import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/cli/commands/validate.dart';
import 'package:fantom/src/exceptions/exceptions.dart';
import 'package:fantom/src/utils/constants.dart';
import 'package:fantom/src/utils/logger.dart';
import 'package:fantom/src/utils/update_checker.dart';
import 'package:io/io.dart';

class FantomCli extends CommandRunner<int> {
  static FantomCli createDefaultInstance() {
    return FantomCli([
      GenerateCommand.createDefaultInstance(),
      ValidateCommand(),
    ]);
  }

  FantomCli(List<BaseCommand> commands) : super(kCliName, 'OpenApi Network Client Generator and much more') {
    for (var command in commands) {
      addCommand(command);
    }
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      await _checkIfNewVersionOfThisLibraryIsAvailable();
      final argResults = parse(args);
      var exitCode = await runCommand(argResults);
      return exitCode ?? -1;
    } catch (e, stacktrace) {
      handleExceptions(e, stacktrace);
      if (e is FantomException) {
        return e.exitCode;
      } else {
        return -1;
      }
    } finally {
      if (ConsoleController.isCli) {
        await sharedStdIn.terminate();
      }
    }
  }

  Future _checkIfNewVersionOfThisLibraryIsAvailable() async {
    await UpdateChecker(packageName: kCliName, currentVersion: kCurrentVersion)
        .update()
        .onError((error, stackTrace) => Log.debug('could not check for package new version'))
        .timeout(const Duration(seconds: 4), onTimeout: () {/* do nothing */});
  }
}
