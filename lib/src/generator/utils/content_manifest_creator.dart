import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/mediator/mediator/schema/schema_mediator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/logger.dart';
import 'package:recase/recase.dart';
import 'package:sealed_writer/sealed_writer.dart';

typedef Content = Map<String, MediaType>;

/// is a ManifestGenerator that creates objects that can be used by ComponentGenerators to generate components
///
/// NOTE: an openapi content object in our sdk is represented by a Map<String, MediaType>
class ContentManifestCreator {
  ContentManifestCreator({
    required this.openApi,
    required this.schemaMediator,
    required this.schemaClassGenerator,
  });

  final List<GeneratedSchemaComponent> _generatedComponents = [];
  final OpenApi openApi;
  final SchemaMediator schemaMediator;
  final SchemaClassGenerator schemaClassGenerator;

  ContentManifest? generateContentType({
    required String typeName,
    required String subTypeName,
    required String generatedSchemaTypeName,
    required Content? content,
  }) {
    if (content == null) {
      return null;
    }
    final className = ReCase(typeName).pascalCase;
    final items = List.generate(
      content.entries.length,
      (index) {
        final entry = content.entries.toList()[index];
        final subClassName =
            '${ReCase(subTypeName).pascalCase}${ReCase(_getContentTypeShortName(entry.key)).pascalCase}';
        final subClassShortName = ReCase(entry.key).camelCase;
        return ManifestItem(
          name: subClassName,
          shortName: subClassShortName,
          equality: ManifestEquality.identity,
          fields: [
            _createMediaTypeArguments(
              mediaTypeName: entry.key,
              mediaType: entry.value,
              generatedSchemaTypeName: generatedSchemaTypeName,
            ),
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
    return ContentManifest(
      manifest: manifest,
      generatedComponents: _generatedComponents,
    );
  }

  ManifestField _createMediaTypeArguments({
    required String mediaTypeName,
    required MediaType mediaType,
    required String generatedSchemaTypeName,
  }) {
    final refOrSchema = mediaType.schema;
    String fieldName = ReCase(mediaTypeName).camelCase;
    late String typeName;
    late bool isNullable;
    if (refOrSchema == null) {
      fieldName = 'value';
      typeName = 'dynamic';
      isNullable = false;
    } else {
      late GeneratedSchemaComponent component;
      if (refOrSchema.isReference) {
        Log.debug(refOrSchema.reference.ref);
        component = getGeneratedComponentByRef(refOrSchema.reference.ref)
            as GeneratedSchemaComponent;
      } else {
        // our schema object first needs to be generated and registered
        component = _createSchemaClassFrom(
          refOrSchema,
          '${ReCase(generatedSchemaTypeName).pascalCase}${ReCase(_getContentTypeShortName(mediaTypeName)).pascalCase}'
              .pascalCase,
        );
        _generatedComponents.add(component);
      }

      typeName = component.dataElement.type!;
      isNullable = component.dataElement.isNullable;
    }

    return ManifestField(
      name: fieldName,
      type: ManifestType(
        name: typeName,
        isNullable: isNullable,
      ),
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
class ContentManifest {
  ContentManifest({
    required this.manifest,
    required this.generatedComponents,
  });

  final Manifest manifest;
  final List<GeneratedComponent> generatedComponents;
}
