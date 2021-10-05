import 'dart:async';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:fantom/src/utils/constants.dart';

abstract class BaseCommand<T> extends Command<int> {
  BaseCommand({required this.name, required this.description}) {
    defineCliOptions(argParser);
  }

  @override
  final String name;

  @override
  final String description;

  @override
  String get invocation => '$kCliName $name';

  @override
  FutureOr<int> run() async {
    var arguments = await createArgumnets(argResults!);
    return runCommand(arguments);
  }

  void defineCliOptions(ArgParser argParser);

  FutureOr<T> createArgumnets(ArgResults argResults);

  FutureOr<int> runCommand(T arguments);
}
