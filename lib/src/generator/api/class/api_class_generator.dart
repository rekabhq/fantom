import 'package:equatable/equatable.dart';
import 'package:fantom/src/generator/api/method/api_method_generator.dart';
import 'package:fantom/src/generator/api/sub_class/api_sub_class_generator.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/writer/generatbale_file.dart';

class ApiClassGenerator {
  const ApiClassGenerator({
    required this.openApi,
    required this.apiSubClassGenerator,
    required this.apiMethodGenerator,
  });

  final OpenApi openApi;
  final ApiSubClassGenerator apiSubClassGenerator;
  final ApiMethodGenerator apiMethodGenerator;

  GeneratableFile generate() {
    final fileContent = _generateFileContent();

    //TODO(payam): analyzer file content of the class
    //TODO(payam): format the content of the class

    return GeneratableFile(
      fileContent: fileContent,
      fileName: 'api/fantom.dart',
    );
  }

  String _generateFileContent() {
    //TODO: maybe we can get this somehow from cli
    final apiClassName = 'FantomApi';

    final buffer = StringBuffer();
    buffer
      ..writeln(_generateImports())
      ..writeln(_generateClass(apiClassName))
      ..writeln(_generateConstructor(apiClassName))
      ..writeln(_generateFields())
      ..writeln(_generateSubClassMethods(openApi.paths.paths))
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

    """;
  }

  String _generateSubClassMethods(
    final Map<String, PathItem> paths,
  ) {
    // TODO: add subtype classes
    return """
      

    """;
  }

  List<_PathSection> _createPathSections(Map<String, PathItem> paths) {
    final pathSections = <_PathSection>[];
    // final pathInitiator = _findPathsInitiator(paths.keys.toList());

    return pathSections;
  }

  String _findPathsInitiator(List<String> pathValues) {
    final pathUris = pathValues.map((path) => Uri.parse(path)).toList();

    final initiator = '';

    return initiator;

  }
}

class _PathSection extends Equatable {
  const _PathSection({
    required this.sectionName,
    required this.paths,
  });

  final String sectionName;
  final Map<String, PathItem> paths;

  @override
  List<Object?> get props => [sectionName, paths];
}
