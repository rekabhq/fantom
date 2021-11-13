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

  List<_ApiSection> _createPathSections(Map<String, PathItem> paths) {
    final pathInitiator = _findPathsInitiator(paths.keys.toList());
    final sections = _splitPathSections(
      pathInitiator,
      paths.keys.toList(),
    );

    List<_ApiSection> apis = [];
    for (final section in sections) {
      final apiSections = paths.entries.where(
        (e) => e.key.contains(section),
      );
      if (apiSections.isNotEmpty) {
        apis.add(
          _ApiSection(
            sectionName: section,
            paths: Map.fromEntries(apiSections),
          ),
        );
      }
    }

    return apis;
  }

  String _findPathsInitiator(List<String> pathValues) {
    if (pathValues.isEmpty) return '';

    final pathUris = pathValues.map((path) => Uri.parse(path)).toList();

    int segmentCount = 0;

    String initiator = pathUris.first.pathSegments[segmentCount];

    bool foundInitiator = false;

    while (!foundInitiator) {
      final foundInitiatorInPaths = pathUris.every((path) {
        return path.pathSegments[segmentCount] == initiator;
      });

      if (foundInitiatorInPaths) {
        segmentCount++;
        initiator = pathUris.first.pathSegments[segmentCount];
      } else {
        foundInitiator = true;
      }
    }

    if (segmentCount == 0) return '';

    final initiatorResult =
        pathUris.first.pathSegments.sublist(0, segmentCount).join('/');

    return '/$initiatorResult';
  }

  Set<String> _splitPathSections(String pathInitiator, List<String> list) {
    if (pathInitiator.isEmpty) return list.toSet();

    final Set<String> sections = {};

    for (final path in list) {
      final section = path.replaceFirst(pathInitiator, '');

      sections.add(section);
    }

    return sections;
  }
}

class _ApiSection extends Equatable {
  const _ApiSection({
    required this.sectionName,
    required this.paths,
  });

  final String sectionName;
  final Map<String, PathItem> paths;

  @override
  List<Object?> get props => [sectionName, paths];
}
