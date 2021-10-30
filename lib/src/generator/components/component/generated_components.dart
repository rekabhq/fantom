import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/exceptions.dart';
import 'package:io/io.dart';
import 'package:sealed_writer/sealed_writer.dart';

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
  get fileContent => throw FantomException(
        errorMessage,
        ExitCode.cantCreate.code,
      );
}

class GeneratedContentComponent extends GeneratedComponent {
  GeneratedContentComponent({
    required this.manifest,
    required this.generatedComponents,
    required String fileContent,
    required String fileName,
  }) : super(
          fileContent: fileContent,
          fileName: fileName,
        );

  final Manifest manifest;
  final List<GeneratedSchemaComponent> generatedComponents;
}

class GeneratedParameterComponent extends GeneratedComponent {
  GeneratedParameterComponent({
    required this.source,
    required this.schemaComponent,
    required String fileContent,
    required String fileName,
  }) : super(
          fileContent: fileContent,
          fileName: fileName,
        );

  final GeneratedSchemaComponent schemaComponent;
  final Parameter source;

  DataElement get dataElement => schemaComponent.dataElement;
}

class GeneratedRequestBodyComponent extends GeneratedComponent {
  GeneratedRequestBodyComponent({
    required this.contentComponent,
    required String fileContent,
    required String fileName,
  }) : super(
          fileContent: fileContent,
          fileName: fileName,
        );

  final GeneratedContentComponent contentComponent;
}

class GeneratedResponseComponent extends GeneratedComponent {
  //TODO: add the meta-data about the generated response body class here.
  GeneratedResponseComponent({
    required this.dataElement,
    required this.schemaComponent,
    required String fileContent,
    required String fileName,
  }) : super(
          fileContent: fileContent,
          fileName: fileName,
        );

  final DataElement dataElement;
  final GeneratedSchemaComponent schemaComponent;
}
