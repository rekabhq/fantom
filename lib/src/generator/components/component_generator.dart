import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/components/components_collection.dart';
import 'package:fantom/src/generator/parameter/parameter_class_generator.dart';
import 'package:fantom/src/generator/request_body/requestbody_class_generator.dart';
import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/generator/utils/content_manifest_generator.dart';
import 'package:fantom/src/generator/utils/reference_finder.dart';
import 'package:fantom/src/mediator/mediator/schema/schema_mediator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';

class ComponentsGenerator {
  ComponentsGenerator({
    required this.schemaMediator,
    required this.schemaClassGenerator,
    required this.parameterClassGenerator,
    required this.contentManifestGenerator,
    required this.requestBodyClassGenerator,
  });

  final SchemaMediator schemaMediator;

  final SchemaClassGenerator schemaClassGenerator;

  final ParameterClassGenerator parameterClassGenerator;

  final ContentManifestGenerator contentManifestGenerator;

  final RequestBodyClassGenerator requestBodyClassGenerator;

  factory ComponentsGenerator.createDefault(OpenApi openApi) {
    final schemaMediator = SchemaMediator();
    final schemaGenerator = SchemaClassGenerator();
    final contentManifestGenerator = ContentManifestGenerator(
      openApi: openApi,
      schemaMediator: schemaMediator,
      schemaClassGenerator: schemaGenerator,
    );
    final requestBodyClassGenerator = RequestBodyClassGenerator(
      contentManifestGenerator: contentManifestGenerator,
    );
    return ComponentsGenerator(
      requestBodyClassGenerator: requestBodyClassGenerator,
      contentManifestGenerator: contentManifestGenerator,
      schemaMediator: schemaMediator,
      schemaClassGenerator: schemaGenerator,
      parameterClassGenerator: ParameterClassGenerator(
        schemaGenerator: schemaGenerator,
        schemaMediator: schemaMediator,
        contentManifestGenerator: contentManifestGenerator,
      ),
    );
  }

  void generateAndRegisterComponents(OpenApi openApi) {
    List<Map<String, GeneratedComponent>> allGeneratedComponents = [];

    final schemaComponents = (openApi.components?.schemas == null)
        ? <String, GeneratedSchemaComponent>{}
        : _generateSchemas(
            openApi,
            openApi.components!.schemas!,
          );

    final parameterComponents = (openApi.components?.parameters == null)
        ? <String, GeneratedParameterComponent>{}
        : _generateParameters(
            openApi,
            openApi.components!.parameters!,
          );

    allGeneratedComponents.addAll([
      schemaComponents,
      parameterComponents,
    ]);

    for (var map in allGeneratedComponents) {
      map.forEach((ref, component) {
        registerGeneratedComponent(ref, component);
      });
    }
  }

  Map<String, GeneratedSchemaComponent> _generateSchemas(
    OpenApi openApi,
    Map<String, Referenceable<Schema>> schemas,
  ) {
    return schemas.map((ref, schema) {
      var dataElement =
          schemaMediator.convert(openApi: openApi, schema: schema, name: ref);
      return MapEntry(ref, dataElement);
    }).map((ref, element) {
      late GeneratedSchemaComponent component;
      if (element is ObjectDataElement) {
        component = schemaClassGenerator.generate(element);
      } else {
        component = UnGeneratableSchemaComponent(dataElement: element);
      }
      return MapEntry(ref, component);
    });
  }

  Map<String, GeneratedParameterComponent> _generateParameters(
    OpenApi openApi,
    Map<String, Referenceable<Parameter>> parameters,
  ) {
    final referenceFinder = ReferenceFinder(openApi: openApi);
    return parameters.map(
      (key, value) {
        return MapEntry(
          key,
          parameterClassGenerator.generate(
            openApi,
            value.isValue
                ? value.value
                : referenceFinder.findParameter(value.reference),
            key,
          ),
        );
      },
    );
  }
}
