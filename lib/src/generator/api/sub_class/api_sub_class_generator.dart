import 'package:fantom/src/generator/api/api_constants.dart';
import 'package:fantom/src/generator/api/method/api_method_generator.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/writer/generatbale_file.dart';
import 'package:recase/recase.dart';

class ApiSubClassGenerator {
  const ApiSubClassGenerator({
    required this.apiMethodGenerator,
  });

  final ApiMethodGenerator apiMethodGenerator;

  GeneratableFile generate({
    required final String subClassName,
    required final Map<String, PathItem> paths,
  }) {
    final fileContent = _generateFileContent(subClassName, paths);

    return GeneratableFile(
      fileContent: fileContent,
      fileName: 'api/${subClassName.snakeCase}.dart',
    );
  }

  String _generateFileContent(
    final String subClassName,
    final Map<String, PathItem> paths,
  ) {
    final buffer = StringBuffer();
    buffer
      ..writeln(_generateImports())
      ..writeln(_generateClass(subClassName))
      ..writeln(_generateConstructor(subClassName))
      ..writeln(_generateFields())
      ..writeln(_generateApiMethods(paths))
      ..writeln('}');

    return buffer.toString();
  }

  String _generateImports() {
    //TODO(payam): add models import

    return """
    import 'package:dio/dio.dart';
    """;
  }

  String _generateClass(String className) {
    return """
    class $className {

    
    """;
  }

  String _generateConstructor(String className) {
    return """
    $className({required this.dio});
    """;
  }

  String _generateFields() {
    return """
    final Dio dio;

    final $parameterParserVarName = MethodUriParser();
    """;
  }

  String _generateApiMethods(Map<String, PathItem> paths) {
    return """
    
    ${apiMethodGenerator.generateMethods(paths)}

    """;
  }
}
