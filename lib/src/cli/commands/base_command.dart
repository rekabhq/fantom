import 'dart:async';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:fantom/src/utils/constants.dart';

/// [BaseCommand] is a generic CLI Command that can be added to fantom-cli
///
/// [BaseCommand] has an argument object of type [T] which will be created from cli options input user has entered
/// and later will be used by [runCommand] method. [runCommand] does the actual that [BaseCommand] implementations are
/// supposed to do.
///
/// to create a new CustomCommand that extends [BaseCommand] a [name], [description] of the command and at last
/// 3 lifecycle callbacks which are [defineCliOptions], [createArguments] and [runCommand] must be implemented
///
/// [BaseCommand]'s lifecycle method are ran in the said order and note that [runCommand] will be called immediately after
/// [createArguments] and uses its return type as arguments
abstract class BaseCommand<T> extends Command<int> {
  BaseCommand({required this.name, required this.description}) {
    defineCliOptions(argParser);
  }

  /// name of this command
  @override
  final String name;

  /// description for this command, description will be shown as help in fantom cli
  @override
  final String description;

  /// the command that invokes this command
  @override
  String get invocation => '$kCliName $name';

  @override
  FutureOr<int> run() async {
    var arguments = await createArguments(argResults!);
    return runCommand(arguments);
  }

  /// here we define cli options and flag for our command
  void defineCliOptions(ArgParser argParser);

  /// here we create an argument object of type [T] that later will be used by [runCommand] method to run the command
  /// using user's input cli options
  ///
  /// this method must be overrided to create an argument object of type [T] from the cli options user
  /// has entered when calling our this comamnd. simpley get the cli options user entered from [argResults]
  /// and return an argument object of type [T]
  ///
  FutureOr<T> createArguments(ArgResults argResults);

  /// whatever this command is supposed to achieved will be achieved from this method
  /// using the [arguments] provided and returns ans exitcode [int] value
  FutureOr<int> runCommand(T arguments);
}
