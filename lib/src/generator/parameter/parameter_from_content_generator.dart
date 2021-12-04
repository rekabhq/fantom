import 'package:fantom/src/generator/components/components.dart';
import 'package:fantom/src/generator/schema/schema_to_json_generator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:recase/recase.dart';

class _ParamInfo {
  final String propertyName;
  final String propertyType;
  final String namedFactoryMethodName;
  final String contentType;
  final DataElement dataElement;

  _ParamInfo({
    required this.propertyName,
    required this.propertyType,
    required this.namedFactoryMethodName,
    required this.contentType,
    required this.dataElement,
  });
}

String createParameterClassFromContent({
  required String typeName,
  required Map<String, GeneratedSchemaComponent> contentMap,
}) {
  List<_ParamInfo> paramInfos = [];
  // add data for each content type this body can get
  for (var entry in contentMap.entries) {
    final contentType = entry.key;
    final component = entry.value;
    var propertyType = component.dataElement.type;
    if (!propertyType.endsWith('?')) {
      propertyType += '?';
    }
    final shortContentTypeName = getContentTypeShortName(contentType);
    paramInfos.add(
      _ParamInfo(
        propertyName: shortContentTypeName.camelCase,
        propertyType: propertyType,
        namedFactoryMethodName: shortContentTypeName.camelCase,
        contentType: contentType,
        dataElement: component.dataElement,
      ),
    );
  }
  final buffer = StringBuffer();
  // class open
  buffer.writeln('class $typeName {');
  // class properties
  for (var info in paramInfos) {
    buffer.writeln('final ${info.propertyType} ${info.propertyName};');
  }
  // add custom body property
  // create private constructor
  buffer.writeln('$typeName._(');
  for (var i = 0; i < paramInfos.length; i++) {
    final info = paramInfos[i];
    buffer.writeln('this.${info.propertyName}');
    if (i + 1 != paramInfos.length) {
      buffer.write(',');
    }
  }
  buffer.writeln(');\n');
  // create factory constructors
  for (var i = 0; i < paramInfos.length; i++) {
    final info = paramInfos[i];
    buffer.writeln(
        'factory $typeName.${info.namedFactoryMethodName}(${info.propertyType} ${info.propertyName}) => $typeName._(');
    for (var j = 0; j < paramInfos.length; j++) {
      if (j == i) {
        buffer.writeln(info.propertyName);
      } else {
        buffer.writeln('null');
      }
      if (j + 1 != paramInfos.length) {
        buffer.write(',');
      }
    }
    buffer.writeln(');\n');
  }
  // create contentType getter
  buffer.writeln('String? get contentType{');
  for (var info in paramInfos) {
    buffer.writeln('if(${info.propertyName} != null)');
    buffer.writeln("return '${info.contentType}';");
  }
  buffer.writeln('return null;');
  buffer.writeln('}\n');
  // class toUriParam method
  buffer.writeln(
      'UriParam toUriParam(String name, String style, bool explode) {');
  for (var info in paramInfos) {
    if (info.contentType == 'application/json') {
      buffer.writeln('if(${info.propertyName} != null){');
      final toJsonGen = generateJsonSerilzationBoilerplateFor(
        element: info.dataElement,
        objectName: '${info.propertyName}!',
        serializedObjectName: 'paramValue',
      );
      buffer.writeln(toJsonGen);
      if (info.dataElement.isObjectDataElement) {
        buffer.writeln(
            'return UriParam.object(name, paramValue, style, explode);');
      } else if (info.dataElement.isArrayDataElement) {
        buffer.writeln(
            'return UriParam.array(name, paramValue, style, explode);');
      } else {
        buffer.writeln(
            'return UriParam.primitive(name, paramValue, style, explode);');
      }
      buffer.writeln('}');
    } else {
      buffer.writeln(
          '/// content type ${info.contentType} is not yet supported for parameters');
    }
  }
  buffer.writeln(
      "throw Exception('fantom cannot create a UriParam from type -> \$runtimeType');");
  buffer.writeln('}\n');
  // class end
  buffer.writeln('}');
  return buffer.toString();
}
