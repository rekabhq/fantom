import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/parameter/parameter_class_generator.dart';
import 'package:fantom/src/generator/request_body/requestbody_class_generator.dart';
import 'package:fantom/src/generator/response/response_class_generator.dart';
import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/generator/utils/content_manifest_creator.dart';
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
    required this.contentManifestGenerator,
    required this.parameterClassGenerator,
    required this.requestBodyClassGenerator,
    required this.responseClassGenerator,
  });

  final OpenApi openApi;

  final SchemaMediator schemaMediator;

  final ReferenceFinder referenceFinder;

  final SchemaClassGenerator schemaClassGenerator;

  final ContentManifestCreator contentManifestGenerator;

  final ParameterClassGenerator parameterClassGenerator;

  final RequestBodyClassGenerator requestBodyClassGenerator;

  final ResponseClassGenerator responseClassGenerator;

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
      contentManifestGenerator: contentManifestGenerator,
      requestBodyClassGenerator: requestBodyClassGenerator,
      parameterClassGenerator: ParameterClassGenerator(
        schemaGenerator: schemaGenerator,
        schemaMediator: schemaMediator,
        contentManifestGenerator: contentManifestGenerator,
      ),
      responseClassGenerator: ResponseClassGenerator(
        contentManifestCreator: contentManifestGenerator,
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

    // generate and register all responses
    final responseComponents = (openApi.components?.responses == null)
        ? <String, GeneratedResponseComponent>{}
        : _generateResponses(
            openApi.components!.responses!,
          );

    responseComponents.forEach((ref, component) {
      registerGeneratedComponent(ref, component);
    });
  }

  Map<String, GeneratedSchemaComponent> generateSchemas(
    Map<String, Referenceable<Schema>> schemas,
  ) {
    return schemas.map((ref, schema) {
      //TODO: this should be done when we are reading the openapi file not here. lets talk about this payam, amirreza
      return MapEntry(
        '#/components/schemas/$ref',
        schemaMediator.convert(
          openApi: openApi,
          schema: schema,
          name: ref,
        ),
      );
    }).map((ref, element) {
      return MapEntry(
        ref,
        element is ObjectDataElement
            ? schemaClassGenerator.generate(element)
            : UnGeneratableSchemaComponent(dataElement: element),
      );
    });
  }

  Map<String, GeneratedParameterComponent> _generateParameters(
    Map<String, Referenceable<Parameter>> parameters,
  ) {
    return parameters.map(
      (ref, value) {
        return MapEntry(
          '#/components/parameters/$ref',
          parameterClassGenerator.generate(
            openApi,
            value.isValue
                ? value.value
                : referenceFinder.findParameter(value.reference),
            ref,
          ),
        );
      },
    );
  }

  Map<String, GeneratedRequestBodyComponent> _generateRequestBodies(
    Map<String, Referenceable<RequestBody>> requestBodies,
  ) {
    return requestBodies.map((ref, requestBody) {
      final actualReference = '#/components/requestBodies/$ref';
      final component = requestBodyClassGenerator.generate(
        requestBody.isValue
            ? requestBody.value
            : referenceFinder.findRequestBody(requestBody.reference),
        ref,
      );
      return MapEntry(actualReference, component);
    });
  }

  Map<String, GeneratedResponseComponent> _generateResponses(
    Map<String, Referenceable<Response>> responses,
  ) {
    return responses.map((ref, response) {
      final actualReference = '#/components/responses/$ref';
      final component = responseClassGenerator.generateResponse(
        response.isValue
            ? response.value
            : referenceFinder.findResponse(response.reference),
        ref,
      );
      return MapEntry(actualReference, component);
    });
  }
}
