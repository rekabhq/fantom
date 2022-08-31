import 'dart:io';
import 'package:dart_style/dart_style.dart';
import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/utils/constants.dart';
import 'package:fantom/src/utils/extensions.dart';
import 'package:fantom/src/generator/utils/generation_data.dart';
import 'package:fantom/src/utils/logger.dart';
import 'package:fantom/src/utils/process_manager.dart';
import 'package:fantom/src/writer/dart_package.dart';
import 'package:fantom/src/writer/directive.dart';
import 'package:fantom/src/writer/generatbale_file.dart';
import 'package:fantom/src/writer/utility_files.dart';

// ignore_for_file: unused_local_variable

class FileWriter {
  FileWriter(this.generationData) {
    if (generationData.config is GenerateAsPartOfProjectConfig) {
      modelsDirPath = (generationData.config as GenerateAsPartOfProjectConfig)
          .outputModelsDir
          .path;
      apisDirPath = (generationData.config as GenerateAsPartOfProjectConfig)
          .outputApisDir
          .path;
    } else {
      var fantomPackageInfo = FantomPackageInfo.fromConfig(
        generationData.config as GenerateAsStandAlonePackageConfig,
      );
      modelsDirPath = fantomPackageInfo.modelsDirPath;
      apisDirPath = fantomPackageInfo.apisDirPath;
      packageName = fantomPackageInfo.name;
    }
  }

  final _formatter = DartFormatter();
  final GenerationData generationData;
  late String modelsDirPath;
  late String apisDirPath;
  String? packageName;

  Future writeGeneratedFiles() async {
    if (generationData.config is GenerateAsPartOfProjectConfig) {
      await _writeGeneratedFilesToProject(
        generationData.models,
        generationData.resourceApiClasses,
        generationData.apiClass,
        false,
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

  Future _writeGeneratedFilesToProject(
    List<GeneratedFile> models,
    List<GeneratedFile> resourceApiClasses,
    GeneratedFile apiClass,
    bool isFantomPackage,
  ) async {
    // deleting old models and api files
    await _deleteOldGeneratedFilesFromDirectory(apisDirPath);
    await _deleteOldGeneratedFilesFromDirectory(modelsDirPath);

    // writing models to models path
    final apiClassImports = <Directive>[];
    final modelsFileDirectives = <Directive>[
      Directive.import('package:dio/dio.dart'),
    ];
    for (var model in models) {
      await _createGeneratedFileIn(
        model,
        modelsDirPath,
        [Directive.partOf('models.dart')],
      );
      modelsFileDirectives.add(Directive.part(model.fileName));
    }

    // writing utility files to utils dir
    final allUtilityFiles = await getUtilityFiles();
    for (var utilFile in allUtilityFiles) {
      await _createGeneratedFileIn(
        utilFile,
        '$apisDirPath/utils',
        [],
      );
      if (utilFile.directives.isNotEmpty) {
        apiClassImports.insertAll(0, utilFile.directives);
        modelsFileDirectives.insertAll(0, utilFile.directives);
      }
      apiClassImports.add(_createImport(
        directiveFilePath: '$apisDirPath/utils/${utilFile.fileName}',
        filePath: '$apisDirPath/api.dart',
      ));
      modelsFileDirectives.insert(
        0,
        _createImport(
          directiveFilePath: '$apisDirPath/utils/${utilFile.fileName}',
          filePath: '$modelsDirPath/models.dart',
        ),
      );
    }

    // create models.dart file
    await _createGeneratedFileIn(
      GeneratedFile(fileContent: '', fileName: 'models.dart'),
      modelsDirPath,
      modelsFileDirectives,
    );

    // writing resources api classes to api path
    for (var resourceApi in resourceApiClasses) {
      await _createGeneratedFileIn(
        resourceApi,
        apisDirPath,
        [
          Directive.relative(
            filePath: '$apisDirPath/${resourceApi.fileName}',
            directiveFilePath: '$apisDirPath/api.dart',
            type: DirectiveType.partOf,
          ),
        ],
      );

      apiClassImports.insertAtEnd(
        Directive.relative(
          filePath: '$apisDirPath/api.dart',
          directiveFilePath: '$apisDirPath/${resourceApi.fileName}',
          type: DirectiveType.part,
        ),
      );
    }

    //writing api class to apis path
    apiClassImports.insert(
      0,
      _createImport(
        directiveFilePath: '$modelsDirPath/models.dart',
        filePath: '$apisDirPath/api.dart',
      ),
    );
    await _createGeneratedFileIn(
      apiClass,
      apisDirPath,
      apiClassImports,
    );
  }

  Future _writeGeneratedFilestToPackage(GenerationData data) async {
    var models = data.models;
    var apiClass = data.apiClass;
    var resourceApiClasses = data.resourceApiClasses;
    var config = data.config as GenerateAsStandAlonePackageConfig;
    var fantomPackageInfo = FantomPackageInfo.fromConfig(
      data.config as GenerateAsStandAlonePackageConfig,
    );
    await createDartPackage(fantomPackageInfo);
    await _writeGeneratedFilesToProject(
      models,
      resourceApiClasses,
      apiClass,
      true,
    );
    await runFromCmd('dart', args: [
      'pub',
      'get',
      '--directory=${config.outputModuleDir.path}/${config.packageName}'
    ]);
  }

  Future _createGeneratedFileIn(
    GeneratedFile file,
    String path,
    List<Directive> directives,
  ) async {
    var modelFile = File('$path/${file.fileName}');
    await modelFile.create(recursive: true);
    final content = StringBuffer();
    if (file.fileName.endsWith('.dart')) {
      content.writeln(kFantomFileHeader);
    }
    for (var directive in directives.toSet()) {
      content.writeln(directive.toString());
    }
    content.writeln(file.fileContent);
    var formattedContent = _formatter.tryFormat(
      content.toString(),
      fileName: file.fileName,
    );
    await modelFile.writeAsString(formattedContent);
  }

  Directive _createImport({
    required String directiveFilePath,
    required String filePath,
  }) {
    if (packageName != null) {
      return Directive.absolute(
        directiveFilePath: directiveFilePath,
        type: DirectiveType.import,
        package: packageName!,
      );
    } else {
      return Directive.relative(
        filePath: filePath,
        directiveFilePath: directiveFilePath,
        type: DirectiveType.import,
      );
    }
  }

  Future _deleteOldGeneratedFilesFromDirectory(String dirPath) async {
    final directory = Directory(dirPath);

    if (directory.existsSync()) {
      final children = directory.listSync().whereType<File>();
      for (var file in children) {
        Log.debug(file.path);

        final content = await file.readAsString();
        if (content.contains(kFantomFileHeader)) {
          await file.delete();
        }
      }
    }
  }
}
