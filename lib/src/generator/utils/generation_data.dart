import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/writer/file_writer.dart';

class GenerationData {
  final GenerateConfig config;
  final List<GeneratableFile> models;
  final GeneratableFile apiClass;

  GenerationData({
    required this.config,
    required this.models,
    required this.apiClass,
  });
}
