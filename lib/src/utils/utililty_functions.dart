import 'dart:convert';
import 'dart:io';

import 'package:fantom/src/exceptions/exceptions.dart';
import 'package:fantom/src/extensions/extensions.dart';
import 'package:yaml/yaml.dart';

/// checks [path] to file and if a file exists there a it will be returned otherwise
/// a [FantomException] with message [notFoundErrorMessage] will be thrown
Future<File> getFileInPath({required String? path, required String notFoundErrorMessage}) async {
  if (path.isNullOrBlank) {
    throw NoSuchFileException(notFoundErrorMessage, 'path of file was null or blank');
  }
  var file = File(path!);
  if (await file.exists()) {
    return file;
  } else {
    throw NoSuchFileException(notFoundErrorMessage, path);
  }
}

/// checks [path] to directory and if a directory exists or can be created there a directory will be returned otherwise
/// a [FantomException] with message [directoryPathIsNotValid] will be thrown
Future<Directory> getDirectoryInPath({required String? path, required String directoryPathIsNotValid}) async {
  if (path.isNullOrBlank) {
    throw CannotCreateDirectoryException(directoryPathIsNotValid, 'path of directory was null or blank');
  }
  var directory = Directory(path!);

  try {
    if (await directory.exists()) {
      return directory;
    } else {
      await directory.create(recursive: true);
      return directory;
    }
  } catch (e, _) {
    throw CannotCreateDirectoryException(directoryPathIsNotValid, path);
  }
}

/// reads a the content of a json/yaml file and returns it as a [Map<String,dynamic>]
/// the method samrtly :D differs yaml files from json files
///
/// if the provided file is not json or yaml or the content is not valid an [UnsupportedFileException] will be thrown
Future<Map<String, dynamic>> readJsonOrYamlFile(File file) async {
  var fileContent = await file.readAsString();
  try {
    if (fileContent.startsWith('{')) {
      var json = jsonDecode(fileContent);
      return json;
    } else {
      YamlMap yaml = loadYaml(fileContent);
      var map = yaml.map((key, value) => MapEntry(key.toString(), value));
      return map;
    }
  } catch (e, _) {
    throw UnsupportedFileException(
      'Unsupported File: make sure the file content is in correct json or yaml format',
      file.path,
    );
  }
}
