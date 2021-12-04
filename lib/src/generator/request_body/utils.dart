import 'package:fantom/src/generator/components/components.dart';
import 'package:fantom/src/generator/schema/schema_to_json_generator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:recase/recase.dart';

class _RequestBodyInfo {
  final String propertyName;
  final String propertyType;
  final String namedFactoryMethodName;
  final String contentType;
  final DataElement? dataElement;

  _RequestBodyInfo({
    required this.propertyName,
    required this.propertyType,
    required this.namedFactoryMethodName,
    required this.contentType,
    required this.dataElement,
  });
}

String createRequestBodyClass(
  String typeName,
  Map<String, GeneratedSchemaComponent> contentMap,
) {
  List<_RequestBodyInfo> requestBodyInfos = [];
  // add data for each content type this body can get
  for (var entry in contentMap.entries) {
    final contentType = entry.key;
    final component = entry.value;
    var propertyType = component.dataElement.type;
    if (!propertyType.endsWith('?')) {
      propertyType += '?';
    }
    final shortContentTypeName = getContentTypeShortName(contentType);
    requestBodyInfos.add(
      _RequestBodyInfo(
        propertyName: shortContentTypeName.camelCase,
        propertyType: propertyType,
        namedFactoryMethodName: shortContentTypeName.camelCase,
        contentType: contentType,
        dataElement: component.dataElement,
      ),
    );
  }
  // add custom body type
  requestBodyInfos.add(_RequestBodyInfo(
    propertyName: 'custom',
    propertyType: 'dynamic',
    namedFactoryMethodName: 'custom',
    contentType: 'application/json',
    dataElement: null,
  ));
  final buffer = StringBuffer();
  // class open
  buffer.writeln('class $typeName {');
  // class properties
  for (var info in requestBodyInfos) {
    buffer.writeln('final ${info.propertyType} ${info.propertyName};');
  }
  // add custom body property
  // create private constructor
  buffer.writeln('$typeName._(');
  for (var info in requestBodyInfos) {
    buffer.writeln('this.${info.propertyName},');
  }
  buffer.writeln(');\n');
  // create factory constructors
  for (var i = 0; i < requestBodyInfos.length; i++) {
    final info = requestBodyInfos[i];
    buffer.writeln(
        'factory $typeName.${info.namedFactoryMethodName}(${info.propertyType} ${info.propertyName}) => $typeName._(');
    for (var j = 0; j < requestBodyInfos.length; j++) {
      if (j == i) {
        buffer.writeln('${info.propertyName},');
      } else {
        buffer.writeln('null,');
      }
    }
    buffer.writeln(');\n');
  }
  // create contentType getter
  buffer.writeln('String? get contentType{');
  for (var info in requestBodyInfos) {
    buffer.writeln('if(${info.propertyName} != null)');
    buffer.writeln("return '${info.contentType}';");
  }
  buffer.writeln('return null;');
  buffer.writeln('}\n');
  // class toBody method
  buffer.writeln('dynamic toBody(){');
  for (var info in requestBodyInfos) {
    if (info.propertyName == 'custom' ||
        info.contentType != 'application/json') {
      buffer.writeln('if(${info.propertyName} != null){');
      buffer.writeln('return ${info.propertyName};');
      buffer.writeln('}');
    } else {
      buffer.writeln('if(${info.propertyName} != null){');
      final toJsonGen = generateJsonSerilzationBoilerplateFor(
        element: info.dataElement!,
        objectName: '${info.propertyName}!',
        serializedObjectName: 'serialized',
      );
      buffer.writeln(toJsonGen);
      buffer.writeln('return serialized;');
      buffer.writeln('}');
    }
  }
  buffer.writeln('}\n');
  // class end
  buffer.writeln('}');
  return buffer.toString();
}
