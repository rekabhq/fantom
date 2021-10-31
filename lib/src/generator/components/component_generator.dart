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
    required this.openApi,
    required this.schemaMediator,
    required this.schemaClassGenerator,
    required this.parameterClassGenerator,
    required this.contentManifestGenerator,
    required this.requestBodyClassGenerator,
  });

  final OpenApi openApi;

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
      openApi: openApi,
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

  void generateAndRegisterComponents() {
    List<Map<String, GeneratedComponent>> allGeneratedComponents = [];

    final schemaComponents = (openApi.components?.schemas == null)
        ? <String, GeneratedSchemaComponent>{}
        : generateSchemas(
            openApi.components!.schemas!,
          );

    final parameterComponents = (openApi.components?.parameters == null)
        ? <String, GeneratedParameterComponent>{}
        : _generateParameters(
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

  Map<String, GeneratedSchemaComponent> generateSchemas(
    Map<String, Referenceable<Schema>> schemas,
  ) {
    return schemas.map((ref, schema) {
      var dataElement =
          schemaMediator.convert(openApi: openApi, schema: schema, name: ref);
      //TODO: this should be done when we are reading the openapi file not here. lets talk about this payam, amirreza
      return MapEntry('#/components/schemas/$ref', dataElement);
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
