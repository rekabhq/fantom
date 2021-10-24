import 'package:fantom/src/generator/api/method/api_method_generator.dart';
import 'package:fantom/src/openapi/model/model.dart';
import 'package:fantom/src/writer/file_writer.dart';

class ApiClassGenerator {
  final OpenApi openApi;
  final ApiMethodGenerator apiMethodGenerator;

  ApiClassGenerator({
    required this.openApi,
    required this.apiMethodGenerator,
  });

  GeneratableFile generate() {
    final fileContent = _generateFileContent();

    //TODO(payam): analyzer file content of the class
    //TODO(payam): format the content of the class

    return GeneratableFile(
      fileContent: fileContent,
      fileName: 'api.dart',
    );
  }

  String _generateFileContent() {
    final buffer = StringBuffer();

    return '';
  }

  String _generateImports() {
    return """
    
    """;
  }

  String _generateClass({String className = 'FantomApi'}) {
    return """
    
    """;
  }

  String _generateFields() {
    return """
    
    """;
  }

  String _generateConstructor() {
    return """
    
    """;
  }

  String _generateApiMethods() {
    return """
    
    """;
  }
}
