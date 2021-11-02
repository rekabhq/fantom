import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/utils/content_manifest_creator.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:recase/recase.dart';
import 'package:sealed_writer/sealed_writer.dart';

// to avoid confusion between GeneratedResponseComponent & GeneratedResponsesComponent in this code
typedef _ResponsePart = GeneratedResponseComponent;

class ResponseClassGenerator {
  ResponseClassGenerator({required this.contentManifestCreator});

  final ContentManifestCreator contentManifestCreator;

  GeneratedResponseComponent generateResponse(
    final Response response,
    final String seedName,
  ) {
    final typeName = '${seedName}Response';
    final subTypeName = seedName;
    final generatedSchemaTypeName = '${seedName}ResponseBody';

    final contentManifest = contentManifestCreator.generateContentType(
      typeName: typeName,
      subTypeName: subTypeName,
      generatedSchemaTypeName: generatedSchemaTypeName,
      content: response.content,
    );

    if (contentManifest == null) {
      return UnGeneratableResponseComponent(response);
    }
    final forward = SourceWriter(
      contentManifest.manifest,
      referToManifest: false,
    );
    final sealedClassContent = forward.write();
    final buffer = StringBuffer();
    buffer.writeln(sealedClassContent);
    for (final component in contentManifest.generatedComponents) {
      if (component.isGenerated) {
        buffer.writeln(codeSectionSeparator('Generated Type'));
        buffer.writeln(component.fileContent);
      }
    }

    final fileContent = buffer.toString();
    final fileName = '${typeName.snakeCase}.dart';

    return GeneratedResponseComponent(
      fileName: fileName,
      fileContent: fileContent,
      contentManifest: contentManifest,
      source: response,
    );
  }

  GeneratedResponsesComponent generateResponses(
    final Responses responses,
    final String seedName,
  ) {
    List<_ResponsePart> generatedComponents = [];
    // first we get all components for the response parts either by ref or we generate them and map them to our
    // reponse status codes in our responses object
    if (responses.map == null || responses.map?.entries.isEmpty == true) {
      return UnGeneratableResponsesComponent(responses);
    }
    Map<String, _ResponsePart> responseParts = responses.map!.map(
      (statusCode, responseOrRef) {
        if (responseOrRef.isReference) {
          print(responseOrRef.reference.ref);
          var component =
              getGeneratedComponentByRef(responseOrRef.reference.ref)
                  as _ResponsePart;
          return MapEntry(statusCode, component);
        } else {
          var component = generateResponse(responseOrRef.value, seedName);
          generatedComponents.add(component);
          return MapEntry(statusCode, component);
        }
      },
    );

    // last we try to generate our Responses into a generated component
    Map<String, ManifestItem> manifestItems = responseParts.map(
      (statusCode, responsePart) {
        final manifestField = (responsePart.isGenerated)
            ? ManifestField(
                name: ReCase(responsePart.contentManifest!.manifest.name)
                    .camelCase,
                type: ManifestType(
                  name: ReCase(responsePart.contentManifest!.manifest.name)
                      .pascalCase,
                  isNullable: false,
                ),
              )
            : ManifestField(
                name: 'value',
                type: ManifestType(name: 'dynamic', isNullable: false),
              );
        var manifestItem = ManifestItem(
          name: ReCase('Status$statusCode').pascalCase,
          shortName: ReCase('Status$statusCode').camelCase,
          equality: ManifestEquality.identity,
          fields: [manifestField],
        );
        return MapEntry(statusCode, manifestItem);
      },
    );

    var manifest = Manifest(
      name: ReCase('${seedName}Responses').pascalCase,
      items: manifestItems.values.toList(),
      params: [],
      fields: [],
    );

    final forward = SourceWriter(manifest, referToManifest: false);
    final sealedClassContent = forward.write();
    final buffer = StringBuffer();
    buffer.writeln(sealedClassContent);
    for (final component in generatedComponents) {
      if (component.isGenerated) {
        buffer.writeln(codeSectionSeparator('Generated Type'));
        buffer.writeln(component.fileContent);
      }
    }
    final fileContent = buffer.toString();
    final fileName = '${ReCase('${seedName}Responses').snakeCase}.dart';

    return GeneratedResponsesComponent(
      fileContent: fileContent,
      fileName: fileName,
      contentManifest: ContentManifest(
        manifest: manifest,
        generatedComponents: generatedComponents,
      ),
      source: responses,
    );
  }
}
