import 'package:fantom/src/generator/name/method_name_generator.dart';
import 'package:fantom/src/generator/name/utils.dart';
import 'package:recase/recase.dart';

class NameGenerator {
  final MethodNameGenerator _methodNameGenerator;

  const NameGenerator(this._methodNameGenerator);

  /// generates a unique name for the api end point with the given [details]
  String generateMethodName(OperationDetail details) {
    return _methodNameGenerator.generateUniqueName(details);
  }

  /// generates a unique name for the Component type that is going to be generated for this parameter
  String generateParameterName(ParameterDetails details) {
    return '${ReCase(details.methodName).pascalCase}${ReCase(details.name).pascalCase}';
  }

  /// generates a unique name for the Component type that is going to be generated for this parameter
  String generateRequestBodyName(RequestBodyDetails details) {
    var bodyType = '';
    if (details.contentType == 'application/json') {
      bodyType = 'Json';
    } else if (details.contentType == 'application/xml') {
      bodyType = 'Xml';
    } else if (details.contentType == 'multipart/form-data') {
      bodyType = 'Multipart';
    } else if (details.contentType == 'text/plain') {
      bodyType = 'TextPlain';
    } else if (details.contentType == 'application/x-www-form-urlencoded') {
      bodyType = 'FormData';
    }
    return '${ReCase(details.methodName).pascalCase}${bodyType}Body';
  }
}
