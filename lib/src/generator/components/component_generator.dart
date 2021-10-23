import 'package:fantom/src/generator/components/schema/schema.dart';
import 'package:fantom/src/openapi/model/model.dart';
import 'package:version/version.dart';

class ComponentsGenerator {
  final OpenApi openApi;
  // TODO: name SchemaComponentGenerator makes more sense
  final SchemaGenerator schemaGenerator; //other generators are needed as well

  ComponentsGenerator({
    required this.openApi,
    required this.schemaGenerator,
  });

  factory ComponentsGenerator.createDefault(OpenApi openApi) {
    return ComponentsGenerator(
      openApi: openApi,
      schemaGenerator: SchemaGenerator(
        compatibilityMode: openApi.version.compareTo(Version(3, 1, 0)) < 0,
      ), // determin compatibility mode from version
    );
  }

  void generateAndRegisterComponents() {
    // TODO : should generate components from [openApi] and register them using registerComponent() method
  }
}
