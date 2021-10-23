import 'package:fantom/src/writer/directive.dart';

abstract class GeneratbleFile {
  String get fileContent;
}

class DartFile implements GeneratbleFile {
  final List<Directive> directives;
  final String body;
  DartFile({required this.directives, required this.body});

  @override
  String get fileContent {
    var content = '';
    for (var directive in directives) {
      content += '$directive\n';
    }
    content += '\n\n\n';
    content += body;
    return content;
  }
}
