import 'package:fantom/src/generator/components/components.dart';
import 'package:fantom/src/generator/schema/schema_from_json_generator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:recase/recase.dart';

class _ResponseInfo {
  final String statusCode;
  final String contentType;
  final DataElement dataElement;
  late String varType;
  late String propertyName;
  late final String argName;

  _ResponseInfo(this.statusCode, this.contentType, this.dataElement) {
    varType = dataElement.type;
    argName = '${_getContentTypeShortName(contentType).pascalCase}$statusCode'
        .camelCase;
    propertyName = '${varType.camelCase}${argName.pascalCase}'
        .camelCase
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll(' ', '')
        .replaceAll(',', '');
    propertyName = '_$propertyName';

    if (!varType.endsWith('?')) {
      varType += '?';
    }
  }
}

String createSealedResponseType(
  String typeName,
  Map<String, GeneratedResponseComponent> responseParts,
) {
  // calculating all response peroperties
  final allPropertyInfos = <_ResponseInfo>[];
  for (var entry in responseParts.entries) {
    final statusCode = entry.key;
    final component = entry.value;
    for (var contentItem in component.contentTypes.entries) {
      final contentType = contentItem.key;
      final dataElement = contentItem.value.dataElement;
      allPropertyInfos.add(_ResponseInfo(statusCode, contentType, dataElement));
    }
  }
  final buffer = StringBuffer();
  buffer.writeln('class $typeName {');
  // create properties
  for (var propertyInfo in allPropertyInfos) {
    buffer.writeln(
        '// ${propertyInfo.dataElement.type} - ${propertyInfo.contentType} - ${propertyInfo.statusCode}');
    buffer
        .writeln('final ${propertyInfo.varType} ${propertyInfo.propertyName};');
  }
  // create constructors
  buffer.writeln('   $typeName(');
  for (var propertyInfo in allPropertyInfos) {
    buffer.writeln('  this.${propertyInfo.propertyName},');
  }
  buffer.writeln('   );');
  buffer.writeln('\n');

  // create fold method
  buffer.writeln('void fold({');
  // fold method args
  for (var propertyInfo in allPropertyInfos) {
    buffer.writeln(
        'required void Function(${propertyInfo.varType}) ${propertyInfo.argName},');
  }
  buffer.writeln('}){');

  // create fold method body
  for (var propertyInfo in allPropertyInfos) {
    buffer.writeln('if(${propertyInfo.propertyName} != null){');
    buffer
        .writeln('   ${propertyInfo.argName}(${propertyInfo.propertyName}!);');
    buffer.writeln('}');
  }
  buffer.writeln('}');

  // create from method
  buffer.writeln(
      'static $typeName from(Response response, String? responseContentType){');
  buffer.writeln(
      "final contentType = responseContentType ?? response.headers.value('content-type');");
  buffer.writeln(
      "final statusCode = response.statusCode?.toString() ?? 'default';");
  buffer.writeln('final data = response.data;');
  for (var i = 0; i < allPropertyInfos.length; i++) {
    final propertyInfo = allPropertyInfos[i];
    buffer.writeln(
        "if(contentType == '${propertyInfo.contentType}' && statusCode == '${propertyInfo.statusCode}'){");
    buffer.writeln(generateReturnFromJsonBoilerplateFor(
      element: propertyInfo.dataElement,
      jsonObjectName: 'data',
      deserializedObjectName: 'object',
    ));
    buffer.writeln('return $typeName(');
    for (var j = 0; j < allPropertyInfos.length; j++) {
      var argValue = 'null';
      if (j == i) {
        argValue = 'object';
      }
      buffer.writeln('$argValue,');
    }
    buffer.writeln(');');

    buffer.writeln('}');
  }
  buffer.writeln(
    "throw Exception('could not find a match to deserialize a $typeName from)\\n'\n'\\n\$statusCode"
    " & \$contentType & response data => \\n \$data');",
  );
  buffer.writeln('   }');

  // end class curly brace
  buffer.writeln('}');
  return buffer.toString();
}

// String _generateResponsesExtensionMethods(
//   String className,
//   Map<String, GeneratedResponseComponent> responseParts,
// ) {
//   final buffer = StringBuffer();
//   buffer.writeln('\n');
//   buffer.writeln('extension ${className}Ext on $className {');
//   // create from(statusCode, data, contentType) method for the generated Responses type class
//   buffer.writeln(
//     'static $className from(Response response, String? responseContentType,){ ',
//   );
//   buffer.writeln(
//       "final contentType = responseContentType ?? response.headers.value('content-type');");
//   buffer.writeln(
//       "final statusCode = response.statusCode?.toString() ?? 'default';");
//   buffer.writeln('final data = response.data;');
//   for (var entry in responseParts.entries) {
//     final statusCodeValue = entry.key;
//     final responsePart = entry.value;
//     final responseClassName = responsePart.contentManifest?.manifest.name;

//     final methodName = manifestItems[entry.key]!.shortName;
//     if (responseClassName != null) {
//       final argName = ReCase(responseClassName).camelCase;
//       buffer.writeln("if(statusCode == '$statusCodeValue'){");
//       buffer.writeln(
//           'final responseObject =  ${responseClassName}Ext.fromContentType(contentType, data);');
//       buffer
//           .writeln('return $className.$methodName($argName: responseObject);');
//       buffer.writeln('}');
//     } else {
//       buffer.writeln("if(statusCode == '$statusCodeValue'){");
//       buffer.writeln('return $className.$methodName(response: response);');
//       buffer.writeln('}');
//     }
//   }
//   buffer.writeln(
//     "throw Exception('could not find a match to deserialize a $className from)\\n'\n'\\n\$statusCode & \$contentType & \\n \$data');",
//   );

//   buffer.writeln('  }');
//   buffer.writeln('}');
//   buffer.writeln('\n');
//   return buffer.toString();
// }

String _getContentTypeShortName(String contentType) {
  var name = contentType;
  if (contentType == 'application/json') {
    name = 'Json';
  } else if (contentType == 'application/xml') {
    name = 'Xml';
  } else if (contentType == 'multipart/form-data') {
    name = 'Multipart';
  } else if (contentType == 'text/plain') {
    name = 'TextPlain';
  } else if (contentType == 'application/x-www-form-urlencoded') {
    name = 'FormData';
  } else if (contentType == 'any') {
    name = 'Any';
  } else if (contentType.startsWith('image/')) {
    name = 'Image';
  }
  return name;
}

String _fixName(String value) => ReCase(value).camelCase.replaceAll('*', '');
