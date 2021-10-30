import 'dart:io';

import 'package:fantom/src/generator/components/component/generated_components.dart';
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

/// this Error message should only be used when there is something wrong with the provided path to the
/// openapi.yaml file or fantom.yaml file even though they are different files but fantom cli uses
/// the same cli option to accept the path argument to these files like below command
///
/// ```shell
/// $ fantom generate path/to/openapi.yaml
/// $ fantom generate path/to/fantom-config.yaml
/// ```
class IncorrectFilePathArgument extends FantomException {
  IncorrectFilePathArgument(String openapiOrConfigFilePath)
      : super(
          '''
InvalidArgument -> $openapiOrConfigFilePath
Either the file path is invalid or the file is not in correct json or yaml format
please provide a valid path to a valid file which is either an openapi file in yaml or json format

or a fantom config file in yaml format. note that if you are providing a fantom config file make sure it has a
valid fantom config like below

fantom:
  openapi: example/openapi-files/petstore.openapi.yaml
  model-dir: example/models
  api-dir: example/apis

''',
          io.ExitCode.noInput.code,
        );
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
          'path to the openapi file is the least of required arguments by $kPackageName cli. if you are \n'
          'calling (generate) command from your project root directory only openapi path is required and a default\n'
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
          'config file directory was -> $configFilePath',
          io.ExitCode.noInput.code,
        );
}

class UnSupportedOpenApiVersionException extends FantomException {
  UnSupportedOpenApiVersionException(String? version)
      : super(
          'Unsupported openapi version : ${version ?? ''}\n'
          'the version of openapi file provided is not supported by $kCliName cli\n'
          'fantom cli supports openapi files with version :  >=$kMinOpenapiSupportedVersion <$kMaxOpenapiSupportedVersion',
          io.ExitCode.config.code,
        );
}

class InvalidOpenApiFileException extends FantomException {
  InvalidOpenApiFileException([File? file])
      : super(
          'The file provided as an openapi source is not an openapi file\n'
          'A valid openapi file contains an (openapi) property at the top\n'
          'which its value indicated the version of openapi used to describe your api\n'
          'eg:\n'
          '     openapi: 3.0.0',
          io.ExitCode.config.code,
        );
}

class GeneratedComponentAlreadyDefinedException extends FantomException {
  GeneratedComponentAlreadyDefinedException(
      String ref, GeneratedComponent definedComponent)
      : super(
          'Another Component with $ref is already defined'
          'Defined Component\'s name is ',
          io.ExitCode.cantCreate.code,
        );
}

void handleExceptions(e, stacktrace) {
  if (e is FantomException) {
    Log.error('\n❌❌ ${e.message}');
  } else {
    Log.error(e.toString());
    Log.error(stacktrace.toString());
  }
}
