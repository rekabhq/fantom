import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/mediator/mediator/schema/schema_mediator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:recase/recase.dart';
import 'package:sealed_writer/sealed_writer.dart';

class RequestBodyClassGenerator {
  RequestBodyClassGenerator({
    required this.openApi,
    required this.schemaMediator,
    required this.schemaClassGenerator,
  });

  final SchemaMediator schemaMediator;
  final SchemaClassGenerator schemaClassGenerator;
  final OpenApi openApi;

  String generate(
    String name,
    RequestBody requestBody,
  ) {
    List<GeneratedSchemaComponent> genratedComponents = [];
    var typeName = '${ReCase(name).pascalCase}RequestBody';
    var items = List.generate(requestBody.content.entries.length, (index) {
      var entry = requestBody.content.entries.toList()[index];
      var subClassTypeName =
          '${ReCase(name).pascalCase}${ReCase(_getContentTypeShortName(entry.key)).pascalCase}';
      print(subClassTypeName);
      var subClassTypeShortName = ReCase(entry.key).camelCase;
      print(subClassTypeShortName);
      var mediaType = entry.value;
      var refOrSchema = mediaType.schema!;
      late GeneratedSchemaComponent component;
      if (refOrSchema.isReference) {
        //TODO schema might be refrenciable in that case we must first retrive schema
        //and then get our generatedComponent from componentRegistry because it is already registered there
        throw Exception('WWWWWHATTTTT ???');
      } else {
        // our schema object first needs to be generated and registered
        component = _createSchemaClassFrom(
          refOrSchema,
          '${ReCase(name).pascalCase}Body${ReCase(_getContentTypeShortName(entry.key)).pascalCase}'
              .camelCase,
        );
        genratedComponents.add(component);
      }
      return ManifestItem(
        name: subClassTypeName,
        shortName: subClassTypeShortName,
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
    });
    final source = Manifest(
      name: typeName,
      items: items,
      params: [],
      fields: [],
    );

    // final backward = BackwardWriter(source);
    // var contentBack = backward.write();
    final forward = SourceWriter(source, referToManifest: false);
    var sealedClassContent = forward.write();
    var buffer = StringBuffer();
    buffer.writeln(sealedClassContent);
    for (var component in genratedComponents) {
      buffer.writeln(component.fileContent);
    }
    return buffer.toString();
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
