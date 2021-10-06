import 'package:fantom/src/exceptions/base.dart';
import 'package:fantom/src/utils/constants.dart';
import 'package:io/io.dart' as io;

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
