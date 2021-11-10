import 'package:fantom/fantom.dart';
import 'package:fantom/src/cli/commands/generate.dart';
import 'package:io/io.dart';

class MethodReturnType {
  static const String result = 'result';
  static const String simple = 'simple';

  static void check(String type) {
    if (type != result && type != simple) {
      throw FantomException(
        'Invalid ${GenerateCommand.optionMethodRetuenType} : $type\n'
        '${GenerateCommand.optionMethodRetuenType} could only have the following values => $simple, $result',
        ExitCode.config.code,
      );
    }
  }
}
