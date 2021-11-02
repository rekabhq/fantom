import 'dart:io';
import 'package:dart_style/dart_style.dart';
import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/utils/extensions.dart';
import 'package:fantom/src/generator/utils/generation_data.dart';
import 'package:fantom/src/utils/process_manager.dart';
import 'package:fantom/src/writer/dart_package.dart';
import 'package:fantom/src/writer/directive.dart';
import 'package:fantom/src/writer/neccessary_files.dart';

// ignore_for_file: unused_local_variable

class GeneratableFile {
  final String fileContent;

  final String fileName;

  const GeneratableFile({required this.fileContent, required this.fileName});
}

class FileWriter {
  static final _formatter = DartFormatter();

  static Future writeGeneratedFiles(GenerationData generationData) async {
    if (generationData.config is GenerateAsPartOfProjectConfig) {
      await _writeGeneratedFilesToProject(
        generationData.models,
        generationData.apiClass,
        (generationData.config as GenerateAsPartOfProjectConfig)
            .outputModelsDir
            .path,
        (generationData.config as GenerateAsPartOfProjectConfig)
            .outputApisDir
            .path,
        false,
        '',
      );
    } else if (generationData.config is GenerateAsStandAlonePackageConfig) {
      await _writeGeneratedFilestToPackage(generationData);
    } else {
      throw Exception(
        'Unkonwn GenerateConfig for generate command of cli'
        'this should not happen. if you\'re seeing this error please open an issue',
      );
    }
  }

  static Future _writeGeneratedFilesToProject(
    List<GeneratableFile> models,
    GeneratableFile apiClass,
    String modelsDirPath,
    String apisDirPath,
    bool isFantomPackage,
    String fantomPackageName,
  ) async {
    // writing models to models path
    final modelsFileContent = StringBuffer();
    for (var model in models) {
      await _createGeneratableFileIn(
        model,
        modelsDirPath,
        [Directive.partOf('models.dart')],
      );
      modelsFileContent.writeln(Directive.part(model.fileName).toString());
    }
    for (var neccessaryFile in allNeccessaryFiles) {
      await _createGeneratableFileIn(
        neccessaryFile,
        '$modelsDirPath/extra',
        [Directive.partOf('../models.dart')],
      );
      modelsFileContent.writeln(
          Directive.part('extra/${neccessaryFile.fileName}').toString());
    }

    await _createGeneratableFileIn(
      GeneratableFile(
        fileContent: modelsFileContent.toString(),
        fileName: 'models.dart',
      ),
      modelsDirPath,
      [],
    );
    //writing api class to apis path
    late Directive modelsFileImport;
    if (isFantomPackage) {
      final modelsFilePath =
          '${modelsDirPath}models.dart'.replaceAll('//', '/');
      modelsFileImport = Directive.import(
        'package:$fantomPackageName/${modelsFilePath.split('lib/').last}',
      );
    } else {
      final modelsFilePath = '$modelsDirPath/models.dart'.replaceAll('//', '/');

      var uri = modelsFilePath.replaceAll(apisDirPath, '');
      if (uri.startsWith('/')) {
        uri = uri.substring(1);
      }
      modelsFileImport = Directive.import(uri);
    }
    await _createGeneratableFileIn(
      apiClass,
      apisDirPath,
      [modelsFileImport],
    );
  }

  static Future _writeGeneratedFilestToPackage(GenerationData data) async {
    var models = data.models;
    var apiClass = data.apiClass;
    var config = data.config as GenerateAsStandAlonePackageConfig;
    var fantomPackageInfo = FantomPackageInfo.fromConfig(
      data.config as GenerateAsStandAlonePackageConfig,
    );
    await createDartPackage(fantomPackageInfo);
    await _writeGeneratedFilesToProject(
      models,
      apiClass,
      fantomPackageInfo.modelsDirPath,
      fantomPackageInfo.apisDirPath,
      true,
      config.packageName,
    );
    await runFromCmd('dart', args: [
      'pub',
      'get',
      '--directory=${config.outputModuleDir.path}/${config.packageName}'
    ]);
  }

  static Future _createGeneratableFileIn(
    GeneratableFile generatableFile,
    String path,
    List<Directive> directives,
  ) async {
    var modelFile = File('$path/${generatableFile.fileName}');
    await modelFile.create(recursive: true);
    final content = StringBuffer();
    for (var directive in directives) {
      print(directive);
      content.writeln(directive.toString());
    }
    content.writeln(generatableFile.fileContent);
    var formattedContent = _formatter.tryFormat(
      content.toString(),
      fileName: generatableFile.fileName,
    );
    await modelFile.writeAsString(formattedContent);
  }
}
