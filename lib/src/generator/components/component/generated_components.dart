import 'package:fantom/src/generator/utils/content_manifest_creator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/exceptions.dart';
import 'package:io/io.dart';

/// is just a meta-data class that contains the content of the file that is generated for the an openapi component
/// and also a meta-data about what is in the genrated file so that it can be used later by other sections of
/// our [Generator] service
///
/// the [fileContent] & [fileName] is also used by the [FileWriter] service to generate the file
class GeneratedComponent {
  GeneratedComponent({
    required this.fileContent,
    required this.fileName,
  });

  final String fileContent;
  final String fileName;
}

class GeneratedSchemaComponent extends GeneratedComponent {
  GeneratedSchemaComponent({
    required this.dataElement,
    required String fileContent,
    required String fileName,
  }) : super(
          fileContent: fileContent,
          fileName: fileName,
        );

  final DataElement dataElement;
}

class UnGeneratableSchemaComponent extends GeneratedSchemaComponent {
  UnGeneratableSchemaComponent({required DataElement dataElement})
      : super(
          dataElement: dataElement,
          fileContent: '',
          fileName: '',
        );

  static const errorMessage =
      'An UnGeneratableSchemaComponent cannot and should not be '
      'generated thus it cannot have a fileName or a fileContent';

  @override
  String get fileName => throw FantomException(
        errorMessage,
        ExitCode.cantCreate.code,
      );

  @override
  String get fileContent => throw FantomException(
        errorMessage,
        ExitCode.cantCreate.code,
      );
}

class GeneratedParameterComponent extends GeneratedComponent {
  GeneratedParameterComponent._({
    this.schemaComponent,
    this.contentManifest,
    required this.source,
    required String fileContent,
    required String fileName,
  }) : super(
          fileContent: fileContent,
          fileName: fileName,
        );

  factory GeneratedParameterComponent.schema({
    required GeneratedSchemaComponent schemaComponent,
    required Parameter source,
    required String fileContent,
    required String fileName,
  }) =>
      GeneratedParameterComponent._(
        schemaComponent: schemaComponent,
        source: source,
        fileContent: fileContent,
        fileName: fileName,
      );

  factory GeneratedParameterComponent.content({
    required GeneratedContentManifest contentManifest,
    required Parameter source,
    required String fileContent,
    required String fileName,
  }) =>
      GeneratedParameterComponent._(
        contentManifest: contentManifest,
        source: source,
        fileContent: fileContent,
        fileName: fileName,
      );

  final GeneratedSchemaComponent? schemaComponent;
  final GeneratedContentManifest? contentManifest;
  final Parameter source;

  bool get isSchema => schemaComponent != null;

  bool get isContent => contentManifest != null;
}

class GeneratedRequestBodyComponent extends GeneratedComponent {
  GeneratedRequestBodyComponent({
    required this.contentManifest,
    required this.source,
    required String fileContent,
    required String fileName,
  }) : super(
          fileContent: fileContent,
          fileName: fileName,
        );

  final GeneratedContentManifest contentManifest;

  final RequestBody source;
}

class GeneratedResponseComponent extends GeneratedComponent {
  GeneratedResponseComponent({
    required String fileContent,
    required String fileName,
    required this.contentManifest,
    required this.source,
  }) : super(
          fileContent: fileContent,
          fileName: fileName,
        );

  final GeneratedContentManifest contentManifest;
  final Response source;
}

class GeneratedResponsesComponent extends GeneratedComponent {
  GeneratedResponsesComponent({
    required String fileContent,
    required String fileName,
    required this.contentManifest,
    required this.source,
  }) : super(
          fileContent: fileContent,
          fileName: fileName,
        );

  final GeneratedContentManifest contentManifest;
  final Responses source;
}
