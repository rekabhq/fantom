import 'package:fantom/src/utils/constants.dart';
import 'package:io/io.dart' as io;
import 'package:fantom/src/utils/logger.dart';

class FantomException implements Exception {
  const FantomException(this.message, this.exitCode);

  final String message;

  final int exitCode;

  @override
  String toString() {
    return '${super.toString()}\n$message\n';
  }
}

class NoSuchFileException extends FantomException {
  NoSuchFileException(String message, String filePath)
      : super(
          '$message \n'
          'No Such File or Directory in -> $filePath',
          io.ExitCode.noInput.code,
        );
}

class CannotCreateDirectoryException extends FantomException {
  CannotCreateDirectoryException(String message, String dirPath)
      : super(
          '$message \n'
          'Cannot create Directory in path -> $dirPath',
          io.ExitCode.cantCreate.code,
        );
}

class UnsupportedFileException extends FantomException {
  UnsupportedFileException(String message, String filePath)
      : super(
          '$message \n'
          'Unsupported file in path -> $filePath',
          io.ExitCode.osFile.code,
        );
}

class GenerationConfigNotProvidedException extends FantomException {
  GenerationConfigNotProvidedException()
      : super(
          'Not Enough Configuration options provided to generate fantom network client. \n'
          'you must specify where is your openapi file and where you want to generate the network files\n\n'
          '(path | p) to the openapi file and (output | o) directory path is the least\n'
          'of required arguments by $kPackageName cli. if you are calling (generate) command\n'
          'from your project root directory only (path | p) options is required and a default\n'
          'output path in your project\'s lib directory will be used to store generated files\n\n'
          'Please read the documentation for more info on how to provide $kPackageName cli with'
          'the required configuration to generate your network client\n',
          io.ExitCode.noInput.code,
        );
}

class NoFantomConfigFound extends FantomException {
  NoFantomConfigFound(String configFilePath)
      : super(
          'No Fantom Config Found in provided directory for fantom configurations\n'
          '(config | c) directory was -> $configFilePath',
          io.ExitCode.noInput.code,
        );
}

void handleExceptions(e, stacktrace) {
  if (e is FantomException) {
    Log.error('❌❌ ${e.message}');
  } else {
    Log.error(e.toString());
    Log.error(stacktrace.toString());
  }
}
