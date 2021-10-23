import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/generator/api/api_class_generator.dart';
import 'package:fantom/src/generator/api/method/api_method_generator.dart';
import 'package:fantom/src/generator/api/method/params_parser.dart';
import 'package:fantom/src/generator/api/method/response_parser.dart';
import 'package:fantom/src/generator/components/component_generator.dart';
import 'package:fantom/src/generator/components/components_collection.dart';
import 'package:fantom/src/generator/utils/generation_data.dart';
import 'package:fantom/src/openapi/model/model.dart';
import 'package:fantom/src/writer/file_writer.dart';

class Generator {
  final ApiClassGenerator apiClassGenerator;
  final ComponentsGenerator componentsGenerator;

  Generator({
    required this.apiClassGenerator,
    required this.componentsGenerator,
  });

  factory Generator.createDefault(OpenApi openApi) {
    return Generator(
      apiClassGenerator: ApiClassGenerator(
        openApi: openApi,
        apiMethodGenerator: ApiMethodGenerator(
          openApi: openApi,
          methodParamsParser: MethodParamsParser(),
          methodResponseParser: MethodResponseParser(),
        ),
      ),
      componentsGenerator: ComponentsGenerator.createDefault(openApi),
    );
  }

  /// takes an [openApi] object that is read by OpenApiReader class and generates all api and model files using
  /// [apiClassGenerator] and [componentsGenerator] then puts all the generated data in a [GenerationData] object
  /// in order to be written into the corresponding directories by the FileWriter class
  GenerationData generate(OpenApi openApi, GenerateConfig config) {
    componentsGenerator.generateAndRegisterComponents(openApi);
    var apiClassFile = apiClassGenerator.generate();
    // creating GenerationData object
    var modelsFile = allGeneratedComponents
        .map((e) => GeneratbleFile(fileContent: e.fileContent))
        .toList();
    var generationData = GenerationData(
      config: config,
      models: modelsFile,
      apiClass: apiClassFile,
    );
    return generationData;
  }
}
