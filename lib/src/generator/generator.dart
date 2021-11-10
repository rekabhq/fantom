import 'package:fantom/src/cli/commands/generate.dart';
import 'package:fantom/src/cli/options_values.dart';
import 'package:fantom/src/generator/api/api_class_generator.dart';
import 'package:fantom/src/generator/api/method/api_method_generator.dart';
import 'package:fantom/src/generator/api/method/body_parser.dart';
import 'package:fantom/src/generator/api/method/params_parser.dart';
import 'package:fantom/src/generator/api/method/response_parser.dart';
import 'package:fantom/src/generator/components/component_generator.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/name/method_name_generator.dart';
import 'package:fantom/src/generator/name/name_generator.dart';
import 'package:fantom/src/generator/schema/schema_default_value_generator.dart';
import 'package:fantom/src/generator/utils/generation_data.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/writer/generatbale_file.dart';

class Generator {
  final ApiClassGenerator apiClassGenerator;
  final ComponentsGenerator componentsGenerator;

  Generator({
    required this.apiClassGenerator,
    required this.componentsGenerator,
  });

  factory Generator.createDefault(OpenApi openApi, GenerateConfig config) {
    final nameGenerator = NameGenerator(
      MethodNameGenerator(),
    );

    final componentsGenerator = ComponentsGenerator.createDefault(openApi);
    final methodGenerator = ApiMethodGenerator(
      openApi: openApi,
      methodParamsParser: MethodParamsParser(
        parameterClassGenerator: componentsGenerator.parameterClassGenerator,
      ),
      methodBodyParser: MethodBodyParser(
        bodyClassGenerator: componentsGenerator.requestBodyClassGenerator,
      ),
      methodResponseParser: MethodResponseParser(
        responseClassGenerator: componentsGenerator.responseClassGenerator,
      ),
      nameGenerator: nameGenerator,
      defaultValueGenerator: SchemaDefaultValueGenerator(),
      useResult: config.methodReturnType == MethodReturnType.result,
    );
    return Generator(
      apiClassGenerator: ApiClassGenerator(
        openApi: openApi,
        apiMethodGenerator: methodGenerator,
      ),
      componentsGenerator: componentsGenerator,
    );
  }

  /// takes an [openApi] object that is read by OpenApiReader class and generates all api and model files using
  /// [apiClassGenerator] and [componentsGenerator] then puts all the generated data in a [GenerationData] object
  /// in order to be written into the corresponding directories by the FileWriter class
  GenerationData generate(OpenApi openApi, GenerateConfig config) {
    componentsGenerator.generateAndRegisterComponents();
    var apiClassFile = apiClassGenerator.generate();
    // creating GenerationData object
    var modelsFile = allGeneratedComponents
        .where((element) => element.isGenerated)
        .map(
          (e) => GeneratableFile(
            fileContent: e.fileContent,
            fileName: e.fileName,
          ),
        )
        .toList();
    var generationData = GenerationData(
      config: config,
      models: modelsFile,
      apiClass: apiClassFile,
    );
    return generationData;
  }
}
