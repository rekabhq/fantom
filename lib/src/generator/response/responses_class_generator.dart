import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/response/response_class_generator.dart';
import 'package:fantom/src/generator/utils/content_manifest_generator.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:recase/recase.dart';
import 'package:sealed_writer/sealed_writer.dart';

// to avoid confusion between GeneratedResponseComponent & GeneratedResponsesComponent in this code
typedef _ResponsePart = GeneratedResponseComponent;

class ResponsesClassGenerator {
  final ResponseClassGenerator responseClassGenerator;

  const ResponsesClassGenerator({
    required this.responseClassGenerator,
  });

  GeneratedResponsesComponent generate({
    required String seedName,
    required Responses responses,
  }) {
    List<_ResponsePart> generatedComponents = [];
    // first we get all components for the response parts either by ref or we generate them and map them to our
    // reponse status codes in our responses object

    Map<String, _ResponsePart> responseParts = responses.map!.map(
      (statusCode, responseOrRef) {
        if (responseOrRef.isReference) {
          var component =
              getGeneratedComponentByRef(responseOrRef.reference.ref)
                  as _ResponsePart;
          return MapEntry(statusCode, component);
        } else {
          var component =
              responseClassGenerator.generate(responseOrRef.value, seedName);
          generatedComponents.add(component);
          return MapEntry(statusCode, component);
        }
      },
    );

    // last we try to generate our Responses into a generated component
    Map<String, ManifestItem> manifestItems = responseParts.map(
      (statusCode, responsePart) {
        var manifestItem = ManifestItem(
          name: ReCase('Status$statusCode').pascalCase,
          shortName: ReCase('Status$statusCode').camelCase,
          equality: ManifestEquality.identity,
          fields: [
            ManifestField(
              name:
                  ReCase(responsePart.contentManifest.manifest.name).camelCase,
              type: ManifestType(
                name: ReCase(responsePart.contentManifest.manifest.name)
                    .pascalCase,
                isNullable: false,
              ),
            ),
          ],
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
      if (component is! UnGeneratableSchemaComponent) {
        buffer.write(
            '// ####################################################################### ');
        buffer.writeln(component.fileContent);
      }
    }
    final fileContent = buffer.toString();
    final fileName = '${ReCase('${seedName}Responses').snakeCase}.dart';

    return GeneratedResponsesComponent(
      fileContent: fileContent,
      fileName: fileName,
      contentManifest: GeneratedContentManifest(
        manifest: manifest,
        generatedComponents: generatedComponents,
      ),
      source: responses,
    );
  }
}
