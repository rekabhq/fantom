import 'package:fantom/src/generator/components/schema/schema.dart';
import 'package:fantom/src/openapi/model/model.dart';
import 'package:version/version.dart';

class ComponentsGenerator {
  // TODO: name SchemaComponentGenerator makes more sense
  final SchemaGenerator schemaGenerator; //other generators are needed as well

  ComponentsGenerator({
    required this.schemaGenerator,
  });

  factory ComponentsGenerator.createDefault(OpenApi openApi) {
    return ComponentsGenerator(
      schemaGenerator: SchemaGenerator(
        compatibilityMode: openApi.version.compareTo(Version(3, 1, 0)) < 0,
      ), // determin compatibility mode from version
    );
  }

  void generateAndRegisterComponents(OpenApi openApi) {
    // TODO :
    // should generate components from [openApi] using [schemaGenerator] , [requestBodyGenerator] and etc
    // and registers each of the generated components using global registerComponent() method in order to be used later
    //
  }
}
