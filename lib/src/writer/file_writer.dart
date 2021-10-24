import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/extensions/extensions.dart';
import 'package:fantom/src/generator/utils/generation_data.dart';

// ignore_for_file: unused_local_variable

class GeneratableFile {
  final String fileContent;

  final String fileName;

  GeneratableFile({required this.fileContent, required this.fileName});
}

class FileWriter {
  static final _formatter = DartFormatter();

  static Future writeGeneratedFiles(GenerationData generationData) async {
    if (generationData.config is GenerateAsPartOfProjectConfig) {
      await _writeGeneratedFilesToProject(generationData);
    } else if (generationData.config is GenerateAsStandAlonePackageConfig) {
      await _writeGeneratedFilestToPackage(generationData);
    } else {
      throw Exception(
        'Unkonwn GenerateConfig for generate command of cli'
        'this should not happen. if you\'re seeing this error please open an issue',
      );
    }
  }

  static Future _writeGeneratedFilesToProject(GenerationData data) async {
    var models = data.models;
    var apiClass = data.apiClass;
    var config = data.config as GenerateAsPartOfProjectConfig;
    // writing models to models path
    for (var model in models) {
      await _createGeneratableFileIn(model, config.outputModelsDir.path);
    }
    //writing api class to apis path
    await _createGeneratableFileIn(apiClass, config.outputApisDir.path);
  }

  static Future _writeGeneratedFilestToPackage(GenerationData data) async {
    var models = data.models;
    var apiClass = data.apiClass;
    var config = data.config as GenerateAsStandAlonePackageConfig;
  }

  static Future _createGeneratableFileIn(
    GeneratableFile generatableFile,
    String path,
  ) async {
    var modelFile = File('$path/${generatableFile.fileName}');
    await modelFile.create(recursive: true);
    var formattedContent = _formatter.tryFormat(
      generatableFile.fileContent,
      fileName: generatableFile.fileName,
    );
    await modelFile.writeAsString(generatableFile.fileContent);
  }
}
