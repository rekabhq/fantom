///
/// this code has been copied from https://github.com/leoafarias/fvm repo with minor changes
///

import 'dart:io';

import 'package:io/io.dart';

import 'constants.dart';
import 'logger.dart';

/// Process manager
final processManager = ProcessManager(
  stderr: IOSink(consoleController.stderrSink),
  stdout: IOSink(consoleController.stdoutSink),
);

Future<int> runFromCmd(
  String execPath, {
  List<String> args = const [],
  Map<String, String>? environment,
}) async {
  final process = await processManager.spawn(
    execPath,
    args,
    environment: environment,
    workingDirectory: kCurrentDirectory.path,
  );

  exitCode = await process.exitCode;

  return exitCode;
}
