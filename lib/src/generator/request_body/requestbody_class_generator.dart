import 'package:fantom/src/generator/components/components.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/request_body/utils.dart';
import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/mediator/mediator/schema/schema_mediator.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/logger.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:recase/recase.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';

class RequestBodyClassGenerator {
  RequestBodyClassGenerator({
    required this.openApi,
    required this.schemaClassGenerator,
    required this.schemaMediator,
  });

  final OpenApi openApi;
  final SchemaClassGenerator schemaClassGenerator;
  final SchemaMediator schemaMediator;

  GeneratedRequestBodyComponent generate(
    final RequestBody requestBody,
    final String seedName,
  ) {
    final typeName = '${seedName}RequestBody'.pascalCase;
    Log.debug(seedName);
    Log.debug(typeName);
    List<GeneratedSchemaComponent> generatedComponents = [];
    // we need to replace */* with any in our content-types since it cannot be used in code generation
    final removed = requestBody.content.remove('*/*');
    if (removed != null) {
      requestBody.content['any'] = removed;
    }

    Map<String, GeneratedSchemaComponent> map = {};

    for (var entry in requestBody.content.entries) {
      GeneratedSchemaComponent? component;
      final mediaType = entry.value;
      final contentType = entry.key;
      final refOrSchema = mediaType.schema;
      if (refOrSchema != null) {
        if (refOrSchema.isReference) {
          component = getGeneratedComponentByRef(refOrSchema.reference.ref)
              as GeneratedSchemaComponent;
        } else {
          // our schema object first needs to be generated
          component = _createSchemaClassFrom(
            refOrSchema,
            '$typeName${ReCase(getContentTypeShortName(contentType)).pascalCase}'
                .pascalCase,
          );
          generatedComponents.add(component);
        }
      }
      if (component != null) {
        map[contentType] = component;
      }
    }

    final classContent = createRequestBodyClass(typeName, map);
    final buffer = StringBuffer();
    buffer.writeln(classContent);
    for (final component in generatedComponents) {
      if (component.isGenerated) {
        buffer.writeln(codeSectionSeparator(
            'Generated Type ${component.dataElement.name}'));
        buffer.writeln(component.fileContent);
      }
    }
    final fileContent = buffer.toString();
    final fileName = '${ReCase(typeName).snakeCase}.dart';

    return GeneratedRequestBodyComponent(
      fileName: fileName,
      fileContent: fileContent,
      source: requestBody,
      typeName: typeName,
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
}
