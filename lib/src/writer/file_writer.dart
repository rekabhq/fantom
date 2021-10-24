import 'package:fantom/src/utils/extensions.dart';
import 'package:fantom/src/generator/utils/generation_data.dart';

class GeneratableFile {
  final String fileContent;

  final String fileName;

  GeneratableFile({required this.fileContent, required this.fileName});
}

class FileWriter {
  static Future writeGeneratedFiles(GenerationData generationData) async {
    //TODO: should write the api-classes and models to disk based on generation-data
    await 2.secondsDelay();
  }
}
