import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
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
    required this.referenceFinder,
    required this.schemaClassGenerator,
    required this.parameterClassGenerator,
    required this.contentManifestGenerator,
    required this.requestBodyClassGenerator,
  });

  final OpenApi openApi;

  final SchemaMediator schemaMediator;

  final ReferenceFinder referenceFinder;

  final SchemaClassGenerator schemaClassGenerator;

  final ParameterClassGenerator parameterClassGenerator;

  final ContentManifestCreator contentManifestGenerator;

  final RequestBodyClassGenerator requestBodyClassGenerator;

  factory ComponentsGenerator.createDefault(OpenApi openApi) {
    final schemaMediator = SchemaMediator();
    final schemaGenerator = SchemaClassGenerator();
    final contentManifestGenerator = ContentManifestCreator(
      openApi: openApi,
      schemaMediator: schemaMediator,
      schemaClassGenerator: schemaGenerator,
    );
    final requestBodyClassGenerator = RequestBodyClassGenerator(
      contentManifestGenerator: contentManifestGenerator,
    );

    final referenceFinder = ReferenceFinder(openApi: openApi);
    return ComponentsGenerator(
      openApi: openApi,
      schemaMediator: schemaMediator,
      referenceFinder: referenceFinder,
      schemaClassGenerator: schemaGenerator,
      requestBodyClassGenerator: requestBodyClassGenerator,
      contentManifestGenerator: contentManifestGenerator,
      parameterClassGenerator: ParameterClassGenerator(
        schemaGenerator: schemaGenerator,
        schemaMediator: schemaMediator,
        contentManifestGenerator: contentManifestGenerator,
      ),
    );
  }

  void generateAndRegisterComponents() {
    // generate and register all schemas
    final schemaComponents = (openApi.components?.schemas == null)
        ? <String, GeneratedSchemaComponent>{}
        : generateSchemas(
            openApi.components!.schemas!,
          );

    schemaComponents.forEach((ref, component) {
      registerGeneratedComponent(ref, component);
    });


    // generate and register all parameters
    final parameterComponents = (openApi.components?.parameters == null)
        ? <String, GeneratedParameterComponent>{}
        : _generateParameters(
            openApi.components!.parameters!,
          );

    parameterComponents.forEach((ref, component) {
      registerGeneratedComponent(ref, component);
    });


    // generate and register all request-bodies
    final requestBodyComponents = (openApi.components?.requestBodies == null)
        ? <String, GeneratedRequestBodyComponent>{}
        : _generateRequestBodies(
            openApi.components!.requestBodies!,
          );

    requestBodyComponents.forEach((ref, component) {
      registerGeneratedComponent(ref, component);
    });
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

  Map<String, GeneratedRequestBodyComponent> _generateRequestBodies(
    Map<String, Referenceable<RequestBody>> requestBodies,
  ) {
    return requestBodies.map((ref, requestBodyReferenceable) {
      var actualReference = '#/components/requestBodies/$ref';
      final component = requestBodyClassGenerator.generate(
        typeName: '${ref}RequestBody',
        subTypeName: ref,
        generatedSchemaTypeName: '${ref}Body',
        requestBody: requestBodyReferenceable.isValue
            ? requestBodyReferenceable.value
            : referenceFinder
                .findRequestBody(requestBodyReferenceable.reference),
      );
      return MapEntry(actualReference, component);
    });
  }
}
