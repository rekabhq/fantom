import 'package:fantom/src/utils/constants.dart';
import 'package:io/io.dart' as io;
import 'package:fantom/src/utils/logger.dart';

class FantomException implements Exception {
  const FantomException(this.message, this.exitCode);

  final String message;

  final int exitCode;
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
          'There is no Configuration options provided to generate fantom client. \n'
          '(path) to the openapi file and (output) directory path is the least\n'
          ' of required arguments by $kPackageName cli. Please read the documentation for more info\n',
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
