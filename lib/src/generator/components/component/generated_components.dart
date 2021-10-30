import 'package:fantom/src/mediator/model/schema/schema_model.dart';
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
  GeneratedSchemaComponent(
    this.dataElement,
    String fileContent,
    String fileName,
  ) : super(
          fileContent: fileContent,
          fileName: fileName,
        );

  final DataElement dataElement;
}

class UnGeneratableSchemaComponent extends GeneratedComponent {
  UnGeneratableSchemaComponent({required this.dataElement})
      : super(fileContent: '', fileName: '');

  final DataElement dataElement;

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

class GeneratedParameterComponent extends GeneratedComponent {
  //TODO: add the meta-data about the generated parameter class here.
  // note that the meta data should be what we need to know about this generated component
  // so after we generate a class for a Parameter defined in the components we are going to need
  // meta-data about what that generated class is what it has. not everything but the things that we
  // are going to need to use later. the same goes for other sub-classes of [GeneratedComponent]
  GeneratedParameterComponent(
    String fileContent,
    String fileName,
  ) : super(
          fileContent: fileContent,
          fileName: fileName,
        );
}

class GeneratedRequestBodyComponent extends GeneratedComponent {
  //TODO: add the meta-data about the generated request body class here.
  GeneratedRequestBodyComponent(
    String fileContent,
    String fileName,
  ) : super(
          fileContent: fileContent,
          fileName: fileName,
        );
}

class GeneratedResponseComponent extends GeneratedComponent {
  //TODO: add the meta-data about the generated response body class here.
  GeneratedResponseComponent(
    String fileContent,
    String fileName,
  ) : super(
          fileContent: fileContent,
          fileName: fileName,
        );
}
