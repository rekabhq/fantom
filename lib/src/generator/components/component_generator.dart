import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/components/components_collection.dart';
import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/mediator/mediator/schema/schema_mediator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';

class ComponentsGenerator {
  ComponentsGenerator({
    required this.schemaClassGenerator,
    required this.schemaMediator,
  });

  final SchemaClassGenerator schemaClassGenerator;
  final SchemaMediator schemaMediator;

  factory ComponentsGenerator.createDefault(OpenApi openApi) {
    return ComponentsGenerator(
      schemaClassGenerator: SchemaClassGenerator(),
      schemaMediator: SchemaMediator(compatibility: false),
    );
  }

  void generateAndRegisterComponents(OpenApi openApi) {
    List<Map<String, GeneratedComponent>> allGeneratedComponents = [];

    var schemaComponents = _generateSchemas(
      openApi,
      openApi.components!.schemas!,
    );
    allGeneratedComponents.addAll([schemaComponents]);
    for (var map in allGeneratedComponents) {
      map.forEach((ref, component) {
        registerGeneratedComponent(ref, component);
      });
    }
  }

  Map<String, GeneratedComponent> _generateSchemas(
    OpenApi openApi,
    Map<String, Schema> schemas,
  ) {
    return schemas.map((ref, schema) {
      var dataElement =
          schemaMediator.convert(openApi: openApi, schema: schema, name: ref);
      return MapEntry(ref, dataElement);
    }).map((ref, element) {
      late GeneratedComponent component;
      if (element is ObjectDataElement) {
        component = schemaClassGenerator.generate(element);
      } else {
        component = UnGeneratableSchemaComponent(dataElement: element);
      }
      return MapEntry(ref, component);
    });
  }
}
