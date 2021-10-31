import 'package:fantom/src/generator/utils/content_manifest_generator.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:recase/recase.dart';
import 'package:sealed_writer/sealed_writer.dart';

class RequestBodyClassGenerator {
  RequestBodyClassGenerator({
    required this.contentManifestGenerator,
  });

  final ContentManifestGenerator contentManifestGenerator;

  GeneratedRequestBodyComponent generate({
    required String typeName,
    required String subTypeName,
    required String generatedSchemaTypeName,
    required RequestBody requestBody,
  }) {
    final contentManifest = contentManifestGenerator.generateContentType(
      typeName: typeName,
      subTypeName: subTypeName,
      generatedSchemaTypeName: generatedSchemaTypeName,
      content: requestBody.content,
    );

    final forward =
        SourceWriter(contentManifest.manifest, referToManifest: false);
    final sealedClassContent = forward.write();
    final buffer = StringBuffer();
    buffer.writeln(sealedClassContent);
    for (final component in contentManifest.generatedComponents) {
      buffer.writeln(component.fileContent);
    }
    final fileContent = buffer.toString();
    final fileName = '${ReCase(typeName).snakeCase}.dart';

    return GeneratedRequestBodyComponent(
      fileName: fileName,
      fileContent: fileContent,
      contentManifest: contentManifest,
    );
  }
}
