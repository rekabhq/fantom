import 'package:fantom/src/generator/utils/content_manifest_creator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/exceptions.dart';
import 'package:io/io.dart';

abstract class Generatable {
  bool get isGenerated;
}

mixin UnGeneratableComponent {
  static const errorMessage =
      'An UnGeneratableSchemaComponent cannot and should not be '
      'generated thus it cannot have a fileName or a fileContent.\n'
      'Please check if component is generated or not using <<isGenerated>> getter method';

  String get fileName => throw FantomException(
        errorMessage,
        ExitCode.cantCreate.code,
      );

  String get fileContent => throw FantomException(
        errorMessage,
        ExitCode.cantCreate.code,
      );

  bool get isGenerated => false;
}

/// is just a meta-data class that contains the content of the file that is generated for the an openapi component
/// and also a meta-data about what is in the genrated file so that it can be used later by other sections of
/// our [Generator] service
///
/// the [fileContent] & [fileName] is also used by the [FileWriter] service to generate the file
class GeneratedComponent implements Generatable {
  GeneratedComponent({
    required this.fileContent,
    required this.fileName,
  });

  final String fileContent;
  final String fileName;

  @override
  bool get isGenerated => true;
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

class UnGeneratableSchemaComponent extends GeneratedSchemaComponent
    with UnGeneratableComponent {
  UnGeneratableSchemaComponent({required DataElement dataElement})
      : super(
          dataElement: dataElement,
          fileContent: '',
          fileName: '',
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
    required ContentManifest contentManifest,
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
  final ContentManifest? contentManifest;
  final Parameter source;

  bool get isSchema => schemaComponent != null;

  bool get isContent => contentManifest != null;

  bool get isNullable {
    if (!isSchema) return true;

    return schemaComponent!.dataElement.isNullable;
  }
}

class UnGeneratableParameterComponent extends GeneratedParameterComponent
    with UnGeneratableComponent {
  UnGeneratableParameterComponent({
    required Parameter source,
    GeneratedSchemaComponent? schemaComponent,
  }) : super._(
          source: source,
          schemaComponent: schemaComponent,
          fileContent: '',
          fileName: '',
        );
}

class GeneratedRequestBodyComponent extends GeneratedComponent {
  GeneratedRequestBodyComponent({
    this.contentManifest,
    required this.source,
    required String fileContent,
    required String fileName,
  }) : super(
          fileContent: fileContent,
          fileName: fileName,
        );

  final ContentManifest? contentManifest;

  final RequestBody source;
}

class UnGeneratableRequestBodyComponent extends GeneratedRequestBodyComponent
    with UnGeneratableComponent {
  UnGeneratableRequestBodyComponent(RequestBody source)
      : super(
          source: source,
          fileContent: '',
          fileName: '',
        );
}

class GeneratedResponseComponent extends GeneratedComponent {
  GeneratedResponseComponent({
    required String fileContent,
    required String fileName,
    required this.seedName,
    required this.contentManifest,
    required this.source,
  }) : super(
          fileContent: fileContent,
          fileName: fileName,
        );

  final ContentManifest? contentManifest;
  final String seedName;
  final Response source;
}

class UnGeneratableResponseComponent extends GeneratedResponseComponent
    with UnGeneratableComponent {
  UnGeneratableResponseComponent(Response source)
      : super(
          source: source,
          contentManifest: null,
          seedName: 'no seed name',
          fileContent: '',
          fileName: '',
        );
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

  final ContentManifest? contentManifest;
  final Responses source;
}

class UnGeneratableResponsesComponent extends GeneratedResponsesComponent
    with UnGeneratableComponent {
  UnGeneratableResponsesComponent(Responses source)
      : super(
          source: source,
          contentManifest: null,
          fileContent: '',
          fileName: '',
        );
}
