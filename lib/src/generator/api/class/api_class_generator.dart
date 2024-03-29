import 'package:equatable/equatable.dart';
import 'package:fantom/src/generator/api/method/api_method_generator.dart';
import 'package:fantom/src/generator/api/sub_class/api_sub_class_generator.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/writer/generatbale_file.dart';
import 'package:recase/recase.dart';

class ApiClassGenerator {
  const ApiClassGenerator({
    required this.openApi,
    required this.apiSubClassGenerator,
    required this.apiMethodGenerator,
  });

  final OpenApi openApi;
  final ApiSubClassGenerator apiSubClassGenerator;
  final ApiMethodGenerator apiMethodGenerator;

  List<GeneratedFile> generate() {
    final apiClasses = _generateApiClasses();

    return apiClasses;
  }

  List<GeneratedFile> _generateApiClasses() {
    final sections = _createPathSections(openApi.paths.paths);

    final fileContent = _generateFileContent(sections);

    final List<GeneratedFile> apiClassList = [];

    for (final section in sections) {
      final apiClass = apiSubClassGenerator.generate(
        subClassName: '${section.sectionName}Api'.pascalCase,
        paths: section.paths,
      );
      apiClassList.add(apiClass);
    }

    apiClassList.add(
      GeneratedFile(fileContent: fileContent, fileName: 'api.dart'),
    );

    return apiClassList;
  }

  String _generateFileContent(List<_ApiSection> apiSections) {
    //TODO: maybe we can get this somehow from cli
    final apiClassName = 'FantomApi';

    final buffer = StringBuffer();
    buffer
      ..writeln(_generateClass(apiClassName))
      ..writeln(_generateConstructor(apiClassName))
      ..writeln(_generateFields())
      ..writeln(
        _generateSubClassMethods(_createPathSections(openApi.paths.paths)),
      )
      ..writeln('}');

    return buffer.toString();
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
    List<_ApiSection> apiSections,
  ) {
    final buffer = StringBuffer();

    for (final section in apiSections) {
      final sectionName = section.sectionName.split('/').first;
      final subClassName = '${sectionName}Api'.pascalCase;
      final getterName = '${sectionName}Api'.camelCase;

      buffer
          .writeln('$subClassName get $getterName => $subClassName(dio:dio);');
      buffer.write('');
    }

    return buffer.toString();
  }

  List<_ApiSection> _createPathSections(Map<String, PathItem> paths) {
    final pathInitiator = _findPathsInitiator(paths.keys.toList());
    final sections = _splitPathSections(
      pathInitiator,
      paths.keys.toList(),
    );

    final pureSections = _removeDuplicatedSections(sections);

    List<_ApiSection> apis = [];
    for (final section in pureSections) {
      final apiSections = paths.entries.where(
        (e) => e.key.startsWith('/$section'),
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

  Set<String> _removeDuplicatedSections(Set<String> sections) {
    final Set<String> result = {};

    for (var section in sections) {
      if (section.startsWith('/')) section = section.replaceFirst('/', '');

      final split = section.split('/');

      final sectionInitiator = split.first;

      result.add(sectionInitiator);
    }

    return result;
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
