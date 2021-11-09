import 'dart:io';

import 'package:fantom/src/writer/directive.dart';

class GeneratableFile {
  final String fileContent;

  final String fileName;

  late List<Directive> directives;

  GeneratableFile({
    required this.fileContent,
    required this.fileName,
    List<Directive>? directives,
  }) : directives = directives ?? [];

  factory GeneratableFile.fromFile(File file, {String? fileName}) {
    final extractedDirectives = <Directive>[];
    final fileContent = file.readAsLinesSync().map((line) {
      final directive = Directive.tryToCreateFromLine(line);
      if (directive != null) {
        extractedDirectives.add(directive);
      }
      return line;
    }).join('\n');

    return GeneratableFile(
      fileContent: fileContent,
      fileName: fileName ?? file.path,
      directives: extractedDirectives,
    );
  }
}
