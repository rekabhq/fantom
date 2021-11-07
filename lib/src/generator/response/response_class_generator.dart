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
    final subTypeName = '${seedName}Type';
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
    buffer.writeln(contentManifest.extensionMethods);
    final fileContent = buffer.toString();
    final fileName = '${typeName.snakeCase}.dart';

    return GeneratedResponseComponent(
      fileName: fileName,
      fileContent: fileContent,
      seedName: seedName,
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
    if (responses.allResponses.isEmpty ||
        responses.allResponses.entries.isEmpty) {
      return UnGeneratableResponsesComponent(responses);
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
        final manifestItem = ManifestItem(
          name: ReCase('$seedName$statusCode').pascalCase,
          shortName: ReCase('$seedName$statusCode').camelCase,
          equality: ManifestEquality.identity,
          fields: [manifestField],
        );
        return MapEntry(statusCode, manifestItem);
      },
    );

    // check if any of the sub-types of our Responses type has actual usable value
    final usableValues = manifestItems.values
        .where((element) => element.fields[0].type.name != 'dynamic');
    print('usable values -> $usableValues');
    if (usableValues.isEmpty) {
      return UnGeneratableResponsesComponent(responses);
    }

    final manifest = Manifest(
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
    buffer.writeln(
        _generateResponsesExtensionMethods(manifest.name, responseParts));
    final fileContent = buffer.toString();
    final fileName = '${ReCase('${seedName}Responses').snakeCase}.dart';

    return GeneratedResponsesComponent(
      fileContent: fileContent,
      fileName: fileName,
      contentManifest: ContentManifest(
        manifest: manifest,
        extensionMethods: '',
        generatedComponents: generatedComponents,
      ),
      source: responses,
    );
  }

  String _generateResponsesExtensionMethods(
    String className,
    Map<String, _ResponsePart> responseParts,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('\n');
    buffer.writeln('extension ${className}Ext on $className {');
    // create from(statusCode, data, contentType) method for the generated Responses type class
    buffer.writeln(
      'static $className from(String? statusCode, dynamic data, String contentType,){ ',
    );
    for (var entry in responseParts.entries) {
      final statusCodeValue = entry.key;
      final responsePart = entry.value;
      final responseClassName = responsePart.contentManifest?.manifest.name;

      if (statusCodeValue != 'default') {
        if (responseClassName != null) {
          final methodName =
              ReCase('${responsePart.seedName}$statusCodeValue').camelCase;
          final argName = ReCase(responseClassName).camelCase;
          buffer.writeln("if(statusCode == '$statusCodeValue'){");
          buffer.writeln(
              'final response =  ${responseClassName}Ext.fromContentType(contentType, data);');
          buffer.writeln('return $className.$methodName($argName: response);');
          buffer.writeln('}');
        } else {
          buffer.writeln('// ResponsePart ${responsePart.contentManifest}');
        }
      }
    }
    if (responseParts.containsKey('default')) {
      final defaultResponseClassName =
          responseParts['default']?.contentManifest?.manifest.name;
      if (defaultResponseClassName != null) {
        buffer.writeln(
            'final response =  ${defaultResponseClassName}Ext.fromContentType(contentType, data);');
        buffer.writeln('');
      }
    }
    buffer.writeln(
      "throw Exception('could not find a match to deserialize a $className from)\\n'\n'\\n\$statusCode & \$contentType & \\n \$data');",
    );

    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln('\n');
    return buffer.toString();
  }
}
