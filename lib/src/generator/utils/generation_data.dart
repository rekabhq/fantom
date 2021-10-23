import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/writer/file_types.dart';

class GenerationData {
  final GenerateConfig config;
  final List<GeneratbleFile> models;
  final GeneratbleFile apiClass;

  GenerationData({
    required this.config,
    required this.models,
    required this.apiClass,
  });
}
