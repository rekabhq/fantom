import 'package:fantom/src/generator/name/method_name_generator.dart';
import 'package:fantom/src/generator/name/utils.dart';
import 'package:recase/recase.dart';

class NameGenerator {
  final MethodNameGenerator _methodNameGenerator;

  const NameGenerator(this._methodNameGenerator);

  /// generates a unique name for the api end point with the given [operationDetail]
  String generateMethodName(OperationDetail operationDetail) {
    return _methodNameGenerator.generateUniqueName(operationDetail);
  }

  /// generates a unique name for the Component type that is going to be generated for this parameter
  String generateParameterName(ParameterDetails parameterDetails) {
    return '${ReCase(parameterDetails.methodName).pascalCase}${ReCase(parameterDetails.name).pascalCase}';
  }
}
