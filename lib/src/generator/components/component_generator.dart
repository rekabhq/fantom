import 'package:fantom/src/generator/components/components.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/parameter/parameter_class_generator.dart';
import 'package:fantom/src/generator/request_body/requestbody_class_generator.dart';
import 'package:fantom/src/generator/response/response_class_generator.dart';
import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/generator/utils/reference_finder.dart';
import 'package:fantom/src/mediator/mediator/schema/schema_mediator.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/logger.dart';

class ComponentsGenerator {
  ComponentsGenerator({
    required this.openApi,
    required this.schemaMediator,
    required this.referenceFinder,
    required this.schemaClassGenerator,
    required this.parameterClassGenerator,
    required this.requestBodyClassGenerator,
    required this.responseClassGenerator,
  });

  final OpenApi openApi;

  final SchemaMediator schemaMediator;

  final ReferenceFinder referenceFinder;

  final SchemaClassGenerator schemaClassGenerator;

  final ParameterClassGenerator parameterClassGenerator;

  final RequestBodyClassGenerator requestBodyClassGenerator;

  final ResponseClassGenerator responseClassGenerator;

  factory ComponentsGenerator.createDefault(OpenApi openApi) {
    final schemaMediator = SchemaMediator();
    final schemaGenerator = SchemaClassGenerator();
    final requestBodyClassGenerator = RequestBodyClassGenerator(
      openApi: openApi,
      schemaClassGenerator: schemaGenerator,
      schemaMediator: schemaMediator,
    );
    final responseClassGenerator = ResponseClassGenerator(
      openApi: openApi,
      schemaClassGenerator: schemaGenerator,
      schemaMediator: schemaMediator,
    );
    final referenceFinder = ReferenceFinder(openApi: openApi);
    final parameterClassGenerator = ParameterClassGenerator(
      schemaGenerator: schemaGenerator,
      schemaMediator: schemaMediator,
      openApi: openApi,
    );

    return ComponentsGenerator(
      openApi: openApi,
      schemaMediator: schemaMediator,
      referenceFinder: referenceFinder,
      schemaClassGenerator: schemaGenerator,
      requestBodyClassGenerator: requestBodyClassGenerator,
      parameterClassGenerator: parameterClassGenerator,
      responseClassGenerator: responseClassGenerator,
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
        : generateResponses(
            openApi.components!.responses!,
          );

    responseComponents.forEach((ref, component) {
      registerGeneratedComponent(ref, component);
    });
  }

  Map<String, GeneratedSchemaComponent> generateSchemas(
    Map<String, ReferenceOr<Schema>> schemas,
  ) {
    return schemas.map((ref, schema) {
      final schemaRef = '#/components/schemas/$ref';
      Log.debug(schemaRef);
      return MapEntry(
        schemaRef,
        schemaMediator.convert(
          openApi: openApi,
          schema: schema,
          name: ref,
          schemaRef: schemaRef,
        ),
      );
    }).map((ref, element) {
      return MapEntry(
        ref,
        schemaClassGenerator.generateWithEnums(element),
      );
    });
  }

  Map<String, GeneratedParameterComponent> _generateParameters(
    Map<String, ReferenceOr<Parameter>> parameters,
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
    Map<String, ReferenceOr<RequestBody>> requestBodies,
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

  Map<String, GeneratedResponseComponent> generateResponses(
    Map<String, ReferenceOr<Response>> responses,
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
