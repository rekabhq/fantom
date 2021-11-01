import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/utils/content_manifest_generator.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:recase/recase.dart';
import 'package:sealed_writer/sealed_writer.dart';

class ResponseClassGenerator {
  ResponseClassGenerator({required this.contentManifestCreator});

  final ContentManifestCreator contentManifestCreator;

  GeneratedResponseComponent generate(
    final Response response,
    final String seedName,
  ) {
    final typeName = '${seedName}Response';
    final subTypeName = seedName;
    final generatedSchemaTypeName = '${seedName}ResponseBody';

    // TODO: we should support dynamic types
    // for instance if the content is null
    final contentManifest = contentManifestCreator.generateContentType(
      typeName: typeName,
      subTypeName: subTypeName,
      generatedSchemaTypeName: generatedSchemaTypeName,
      // TODO: update this to support dynamic types
      content: response.content!,
    );

    final forward = SourceWriter(
      contentManifest.manifest,
      referToManifest: false,
    );
    final sealedClassContent = forward.write();
    final buffer = StringBuffer();
    buffer.writeln(sealedClassContent);
    for (final component in contentManifest.generatedComponents) {
      if (component is! UnGeneratableSchemaComponent) {
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
}
