import 'package:fantom/src/openapi/model/model.dart';

class ComponentsGenerator {
  //TODO: add schema generator as dependency

  // final SchemaGenerator schemaGenerator;

  ComponentsGenerator();

  factory ComponentsGenerator.createDefault(OpenApi openApi) {
    return ComponentsGenerator();
    // TODO: update this with schemaGenarator and remove commented codes
    // return ComponentsGenerator(
    //   schemaGenerator: SchemaGenerator(
    //     compatibilityMode: openApi.version.compareTo(Version(3, 1, 0)) < 0,
    //   ), // determine compatibility mode from version
    // );
  }

  void generateAndRegisterComponents(OpenApi openApi) {
    // TODO :
    // should generate components from [openApi] using [schemaGenerator] , [requestBodyGenerator] and etc
    // and registers each of the generated components using global registerGeneratedComponent() method in order to be used later
    //
  }
}
