import 'package:fantom/src/generator/components/components.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/response/tuple2.dart';
import 'package:fantom/src/generator/response/utils.dart';
import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/mediator/mediator/schema/schema_mediator.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/logger.dart';
import 'package:recase/recase.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';

// to avoid confusion between GeneratedResponseComponent & GeneratedResponsesComponent in this code
typedef _ResponsePart = GeneratedResponseComponent;

class ResponseClassGenerator {
  ResponseClassGenerator({
    required this.schemaClassGenerator,
    required this.schemaMediator,
    required this.openApi,
  });

  final SchemaClassGenerator schemaClassGenerator;
  final SchemaMediator schemaMediator;
  final OpenApi openApi;

  GeneratedResponseComponent generateResponse(
    final Response response,
    final String seedName,
  ) {
    final typeName = '${seedName}Response';
    List<GeneratedSchemaComponent> generatedComponents = [];
    // we need to replace */* with any in our content-types since it cannot be used in code generation
    final removed = response.content?.remove('*/*');
    if (removed != null) {
      response.content?['any'] = removed;
    }
    Map<String, GeneratedSchemaComponent>? map = response.content?.map(
      (contentType, mediaType) {
        late GeneratedSchemaComponent component;
        final refOrSchema = mediaType.schema!;
        if (refOrSchema.isReference) {
          component = getGeneratedComponentByRef(refOrSchema.reference.ref)
              as GeneratedSchemaComponent;
        } else {
          // our schema object first needs to be generated
          component = _createSchemaClassFrom(
            refOrSchema,
            '${ReCase(typeName).pascalCase}${ReCase(_getContentTypeShortName(_fixName(contentType))).pascalCase}'
                .pascalCase,
          );
          generatedComponents.add(component);
        }
        return MapEntry(contentType, component);
      },
    );

    return GeneratedResponseComponent(
      contentTypes: map ?? {},
      generatedComponents: generatedComponents,
      source: response,
    );
  }

  GeneratedSchemaComponent _createSchemaClassFrom(
    Referenceable<Schema> schema,
    String name,
  ) {
    var dataElement = schemaMediator.convert(
      openApi: openApi,
      schema: schema,
      name: name,
    );
    if (dataElement.isGeneratable) {
      return schemaClassGenerator
          .generateWithEnums(dataElement.asObjectDataElement);
    } else {
      return UnGeneratableSchemaComponent(dataElement: dataElement);
    }
  }

  String _getContentTypeShortName(String contentType) {
    var name = contentType;
    if (contentType == 'application/json') {
      name = 'Json';
    } else if (contentType == 'application/xml') {
      name = 'Xml';
    } else if (contentType == 'multipart/form-data') {
      name = 'Multipart';
    } else if (contentType == 'text/plain') {
      name = 'TextPlain';
    } else if (contentType == 'application/x-www-form-urlencoded') {
      name = 'FormData';
    } else if (contentType == 'any') {
      name = 'Any';
    } else if (contentType.startsWith('image/')) {
      name = 'Image';
    }
    return name;
  }

  String _fixName(String value) => ReCase(value).camelCase.replaceAll('*', '');

  GeneratedResponsesComponent generateResponses(
    final Responses responses,
    final String seedName,
  ) {
    var typeName = ReCase('${seedName}Response').pascalCase;
    // first we get all components for the response parts either by ref or we generate them and map them to our
    // reponse status codes in our responses object
    if (responses.allResponses.isEmpty ||
        responses.allResponses.entries.isEmpty) {
      return UnGeneratableResponsesComponent(source: responses, typeName: null);
    }

    Map<String, _ResponsePart> responseParts = responses.allResponses.map(
      (statusCode, responseOrRef) {
        if (responseOrRef.isReference) {
          final component =
              getGeneratedComponentByRef(responseOrRef.reference.ref)
                  as _ResponsePart;
          return MapEntry(statusCode, component);
        } else {
          final component = generateResponse(
            responseOrRef.value,
            seedName,
          );
          return MapEntry(statusCode, component);
        }
      },
    );

    // check if any of the sub-types of our Responses type has actual usable value to generate
    if (!responseParts.values
        .any((element) => element.contentTypes.entries.isNotEmpty)) {
      Log.debug('there is no usable values');
      return UnGeneratableResponsesComponent(source: responses, typeName: null);
    }
    // check if we have only one type in our openapi Responses model that can be generated into a type
    // if so we will return that type to be used in api methods and not generate a response class
    // for example for getAllPets api method we will could have a List<Pet> as reposne type instead of
    // creating a GetAllPetResponse wich has a List<Pet> inside it. because there is not point creating
    // GetAllPetResponse type that has single property List<Pet>

    // map of status code and schema of each content type
    final allSchemaTypesOfResponseParts =
        <Tuple2<String, GeneratedSchemaComponent>>[];

    for (var entry in responseParts.entries) {
      final responseComponent = entry.value;
      final statusCode = entry.key;
      for (var item in responseComponent.contentTypes.values) {
        allSchemaTypesOfResponseParts.add(Tuple2(statusCode, item));
      }
    }
    if (allSchemaTypesOfResponseParts.length == 1) {
      final schemaComponent = allSchemaTypesOfResponseParts[0].item2;
      final statusCode = allSchemaTypesOfResponseParts[0].item1;
      if (statusCode.startsWith('2')) {
        for (var components in responseParts.values) {
          for (var generatedComponent in components.generatedComponents) {
            if (generatedComponent.isGenerated) {
              registerGeneratedComponentWithoutRef(generatedComponent);
            }
          }
        }
        typeName = schemaComponent.dataElement.type;
        return UnGeneratableResponsesComponent(
          source: responses,
          typeName: typeName,
          dataElement: schemaComponent.dataElement,
        );
      }
    }

    final buffer = StringBuffer();
    buffer.writeln(createSealedResponseType(typeName, responseParts));
    for (var components in responseParts.values) {
      for (var generatedComponent in components.generatedComponents) {
        if (generatedComponent.isGenerated) {
          buffer.writeln(generatedComponent.fileContent);
        }
      }
    }
    final fileContent = buffer.toString();
    final fileName = '${ReCase('${seedName}Response').snakeCase}.dart';

    return GeneratedResponsesComponent(
      fileContent: fileContent,
      fileName: fileName,
      typeName: typeName,
      source: responses,
    );
  }
}
