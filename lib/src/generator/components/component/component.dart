import 'package:fantom/src/writer/directive.dart';
import 'package:fantom/src/writer/file_types.dart';

enum DType { object, array, string, number, integer, boolean }

class Component {
  final String name;
  final DType dType;
  final List<Directive> directives;

  Component({
    required this.name,
    required this.dType,
    required this.directives,
  });
}

class PrimitiveComponent extends Component {
  PrimitiveComponent(String name, DType dType)
      : super(name: name, dType: dType, directives: []);
}

class ObjectComponent extends Component with DartFile {
  final String _body;
  ObjectComponent(
    String name,
    DType dType,
    List<Directive> fileDirectives,
    String fileBody,
  )   : _body = fileBody,
        super(name: name, dType: dType, directives: fileDirectives);

  @override
  String get body => _body;
}
