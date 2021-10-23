import 'package:fantom/src/extensions/extensions.dart';
import 'package:fantom/src/generator/utils/generation_data.dart';

class GeneratbleFile {
  final String fileContent;

  GeneratbleFile({required this.fileContent});
}

class FileWriter {
  static Future writeGeneratedFiles(GenerationData generationData) async {
    //TODO: should write the api-classes and models to disk based on generation-data
    await 2.secondsDelay();
  }
}
