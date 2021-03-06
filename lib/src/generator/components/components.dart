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

class GeneratedEnumComponent extends GeneratedComponent {
  GeneratedEnumComponent({
    required this.dataElement,
    required String fileContent,
    required String fileName,
  }) : super(
          fileContent: fileContent,
          fileName: fileName,
        );

  final DataElement dataElement;
}

class UnGeneratableEnumComponent extends GeneratedEnumComponent
    with UnGeneratableComponent {
  UnGeneratableEnumComponent({required DataElement dataElement})
      : super(
          dataElement: dataElement,
          fileContent: '',
          fileName: '',
        );
}

class GeneratedParameterComponent extends GeneratedComponent {
  GeneratedParameterComponent._({
    this.schemaComponent,
    this.contentTypeName,
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
    required String contentTypeName,
    required Parameter source,
    required String fileContent,
    required String fileName,
  }) =>
      GeneratedParameterComponent._(
        contentTypeName: contentTypeName,
        source: source,
        fileContent: fileContent,
        fileName: fileName,
      );

  final GeneratedSchemaComponent? schemaComponent;
  final String? contentTypeName;
  final Parameter source;

  bool get isSchema => schemaComponent != null;

  bool get isContent => contentTypeName != null;

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
    required this.source,
    required this.typeName,
    required String fileContent,
    required String fileName,
  }) : super(
          fileContent: fileContent,
          fileName: fileName,
        );

  final RequestBody source;
  final String? typeName;
}

class UnGeneratableRequestBodyComponent extends GeneratedRequestBodyComponent
    with UnGeneratableComponent {
  UnGeneratableRequestBodyComponent(RequestBody source)
      : super(
          source: source,
          typeName: null,
          fileContent: '',
          fileName: '',
        );
}

class GeneratedResponseComponent extends GeneratedComponent
    with UnGeneratableComponent {
  GeneratedResponseComponent({
    required this.contentTypes,
    required this.generatedComponents,
    required this.source,
  }) : super(
          fileContent: '',
          fileName: '',
        );

  final Map<String, GeneratedSchemaComponent> contentTypes;
  final List<GeneratedSchemaComponent> generatedComponents;
  final Response source;
}

class GeneratedResponsesComponent extends GeneratedComponent {
  GeneratedResponsesComponent({
    required String fileContent,
    required String fileName,
    required this.typeName,
    required this.source,
    this.dataElement,
  }) : super(
          fileContent: fileContent,
          fileName: fileName,
        );

  final String? typeName;
  final Responses source;
  DataElement? dataElement;
}

class UnGeneratableResponsesComponent extends GeneratedResponsesComponent
    with UnGeneratableComponent {
  UnGeneratableResponsesComponent({
    required Responses source,
    required String? typeName,
    DataElement? dataElement,
  }) : super(
          source: source,
          typeName: typeName,
          fileContent: '',
          fileName: '',
          dataElement: dataElement,
        );
}
