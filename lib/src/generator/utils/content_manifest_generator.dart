import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/mediator/mediator/schema/schema_mediator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:recase/recase.dart';
import 'package:sealed_writer/sealed_writer.dart';

typedef Content = Map<String, MediaType>;

/// is a ManifestGenerator that creates objects that can be used by ComponentGenerators to generate components
///
/// NOTE: an openapi content object in our sdk is represented by a Map<String, MediaType>
class ContentManifestGenerator {
  ContentManifestGenerator({
    required this.openApi,
    required this.schemaMediator,
    required this.schemaClassGenerator,
  });

  final OpenApi openApi;
  final SchemaMediator schemaMediator;
  final SchemaClassGenerator schemaClassGenerator;

  GeneratedContentManifest generateContentType({
    required String typeName,
    required String subTypeName,
    required String generatedSchemaTypeName,
    required Content content,
  }) {
    List<GeneratedSchemaComponent> generatedComponents = [];
    final className = ReCase(typeName).pascalCase;
    final items = List.generate(
      content.entries.length,
      (index) {
        final entry = content.entries.toList()[index];
        final subClassName =
            '${ReCase(subTypeName).pascalCase}${ReCase(_getContentTypeShortName(entry.key)).pascalCase}';
        print(subClassName);
        final subClassShortName = ReCase(entry.key).camelCase;
        print(subClassShortName);
        final mediaType = entry.value;
        final refOrSchema = mediaType.schema!;
        late GeneratedSchemaComponent component;

        /// TODO: find your schema
        /// checkout the _findSchemaElement in parameterClassGenerator class
        if (refOrSchema.isReference) {
          //TODO: schema might be referenceable in that case we must first retrive schema
          //and then get our generatedComponent from componentRegistry because it is already registered there
          throw Exception('WWWWWHATTTTT ???');
        } else {
          // our schema object first needs to be generated and registered
          // TODO: find a way to generate primitive types like String, int and so on
          component = _createSchemaClassFrom(
            refOrSchema,
            '${ReCase(generatedSchemaTypeName).pascalCase}${ReCase(_getContentTypeShortName(entry.key)).pascalCase}'
                .camelCase,
          );
          generatedComponents.add(component);
        }
        return ManifestItem(
          name: subClassName,
          shortName: subClassShortName,
          equality: ManifestEquality.identity,
          fields: [
            ManifestField(
              name: ReCase(entry.key).camelCase,
              type: ManifestType(
                name: component.dataElement.type!,
                isNullable: component.dataElement.isNullable,
              ),
            )
          ],
        );
      },
    );
    final manifest = Manifest(
      name: className,
      items: items,
      params: [],
      fields: [],
    );
    return GeneratedContentManifest(
      manifest: manifest,
      generatedComponents: generatedComponents,
    );
  }

  GeneratedSchemaComponent _createSchemaClassFrom(schema, name) {
    var dataElement = schemaMediator.convert(
      openApi: openApi,
      schema: schema,
      name: ReCase(name).pascalCase,
    );
    if (dataElement is ObjectDataElement) {
      return schemaClassGenerator.generate(dataElement);
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
    } else if (contentType == '*/*') {
      name = 'Unknown';
    } else if (contentType.startsWith('image/')) {
      name = 'Image';
    }
    return name;
  }
}

/// holds the data that can be used by ComponentGenerators to generate components
class GeneratedContentManifest {
  GeneratedContentManifest({
    required this.manifest,
    required this.generatedComponents,
  });

  final Manifest manifest;
  final List<GeneratedSchemaComponent> generatedComponents;
}
