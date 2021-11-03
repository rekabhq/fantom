import 'package:fantom/src/generator/utils/content_manifest_creator.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:recase/recase.dart';
import 'package:sealed_writer/sealed_writer.dart';

class RequestBodyClassGenerator {
  RequestBodyClassGenerator({
    required this.contentManifestGenerator,
  });

  final ContentManifestCreator contentManifestGenerator;

  GeneratedRequestBodyComponent generate(
    final RequestBody requestBody,
    final String seedName,
  ) {
    final typeName = '${seedName}RequestBody';
    final subTypeName = seedName;
    final generatedSchemaTypeName = '${seedName}Body';

    final contentManifest = contentManifestGenerator.generateContentType(
      typeName: typeName,
      subTypeName: subTypeName,
      generatedSchemaTypeName: generatedSchemaTypeName,
      content: requestBody.content,
      generateToBodyMethod: true,
    );

    if (contentManifest == null) {
      return UnGeneratableRequestBodyComponent(requestBody);
    }

    final forward =
        SourceWriter(contentManifest.manifest, referToManifest: false);
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
    final fileName = '${ReCase(typeName).snakeCase}.dart';

    return GeneratedRequestBodyComponent(
      fileName: fileName,
      fileContent: fileContent,
      contentManifest: contentManifest,
      source: requestBody,
    );
  }
}
