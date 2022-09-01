import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:fantom/src/generator/components/components.dart';
import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/mediator/mediator/schema/schema_mediator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/exceptions.dart';
import 'package:fantom/src/utils/extensions.dart';
import 'package:fantom/src/writer/generatbale_file.dart';
import 'package:recase/recase.dart';
import 'package:yaml/yaml.dart';

import 'logger.dart';

GeneratedSchemaComponent createSchemaClassFrom({
  required ReferenceOr<Schema> schema,
  required String name,
  required SchemaMediator schemaMediator,
  required SchemaClassGenerator schemaClassGenerator,
  required OpenApi openApi,
}) {
  var dataElement = schemaMediator.convert(
    openApi: openApi,
    schema: schema,
    name: name,
    schemaRef: schema.isReference ? schema.reference.ref : '',
  );
  if (dataElement.isGeneratable) {
    return schemaClassGenerator
        .generateWithEnums(dataElement.asObjectDataElement);
  } else {
    return UnGeneratableSchemaComponent(dataElement: dataElement);
  }
}

/// checks [path] to file and if a file exists there a it will be returned otherwise
/// a [FantomException] with message [notFoundErrorMessage] will be thrown
Future<File> getFileInPath(
    {required String? path, required String notFoundErrorMessage}) async {
  if (path.isNullOrBlank) {
    throw NoSuchFileException(
        notFoundErrorMessage, 'path of file was null or blank');
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
Future<Directory> getDirectoryInPath(
    {required String? path, required String directoryPathIsNotValid}) async {
  if (path.isNullOrBlank) {
    throw CannotCreateDirectoryException(
        directoryPathIsNotValid, 'path of directory was null or blank');
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
  try {
    var fileContent = await file.readAsString();
    return _readJsonOrYaml(fileContent);
  } catch (e, _) {
    Log.debug(e);
    throw UnsupportedFileException(
      'Unsupported File: make sure the file content is in correct json or yaml format',
      file.path,
    );
  }
}

Map<String, dynamic> readJsonOrYaml(String content) {
  try {
    return _readJsonOrYaml(content);
  } catch (e, _) {
    throw UnsupportedJsonOrYamlException();
  }
}

Map<String, dynamic> _readJsonOrYaml(String content) {
  Log.debug(content.substring(0, 40));
  if (content.startsWith('{')) {
    var json = jsonDecode(content);
    return json;
  } else {
    YamlMap yaml = loadYaml(content);
    var map = jsonDecode(jsonEncode(yaml)) as Map<String, dynamic>;
    return map;
  }
}

/// creates a separator like below in files to separate different types of code that exists in one file
/// for the purpose of better readability
/// ######################################### section ##############################################
String codeSectionSeparator([String? section]) =>
    '\n\n// ######################################'
    '###${section == null ? '' : ' $section '}######'
    '###################################\n\n';

Future<File> getSourceFileAsAsset(String path) async {
  final splitted = path.split('lib/');
  if (splitted.length > 1) {
    path = splitted.last;
  }
  final uri = await Isolate.resolvePackageUri(
      Uri(scheme: 'package', path: 'fantom/$path'));
  final filePath = uri!.toFilePath(windows: Platform.isWindows);
  return File(filePath);
}

Future<GeneratedFile> createGeneratedFileFromSourceFile({
  required String fileName,
  required String relativePath,
}) async {
  final file = await getSourceFileAsAsset(relativePath);
  return GeneratedFile.fromFile(
    file,
    fileName: fileName,
  );
}

String getContentTypeShortName(String contentType) {
  var name = ReCase(contentType).camelCase.replaceAll('*', '');
  if (contentType == 'application/json') {
    name = 'Json';
  } else if (contentType == 'application/xml') {
    name = 'Xml';
  } else if (contentType == 'multipart/form-data') {
    name = 'Multipart';
  } else if (contentType == 'text/plain') {
    name = 'TextPlain';
  } else if (contentType == 'application/x-www-form-urlencoded') {
    name = 'FormData';
  } else if (contentType == 'any') {
    name = 'Any';
  } else if (contentType.startsWith('image/')) {
    name = 'Image';
  }
  return name;
}
