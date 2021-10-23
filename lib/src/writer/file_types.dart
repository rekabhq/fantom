import 'package:fantom/src/writer/directive.dart';

abstract class GeneratbleFile {
  String get fileContent;
}

mixin DartFile implements GeneratbleFile {

  List<Directive> get directives;

  String get body;

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
