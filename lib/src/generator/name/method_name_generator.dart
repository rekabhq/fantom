import 'package:fantom/src/generator/model/operation_detail.dart';
import 'package:recase/recase.dart';

class MethodNameGenerator {
  final Map<String, OperationDetail> namesHistory;

  MethodNameGenerator([Map<String, OperationDetail>? generatedNamesHistory])
      : namesHistory = generatedNamesHistory ?? {};

  String _generateName(OperationDetail operationDetail) {
    if (operationDetail.operationId?.isNotEmpty ?? false) {
      return ReCase(operationDetail.operationId!).camelCase;
    } else {
      return _generatePathName(
        operationDetail.path,
        operationDetail.operationType,
      );
    }
  }

  String generateUniqueName(OperationDetail operationDetail) {
    String methodName = _generateName(operationDetail);
    int counter = 1;

    while (namesHistory.keys.contains(methodName)) {
      if (methodName.endsWith(counter.toString())) {
        methodName = methodName.substring(
          0,
          methodName.length - counter.toString().length,
        );
      }

      counter++;

      methodName = '$methodName$counter';
    }
    namesHistory[methodName] = operationDetail;
    return methodName;
  }

  String _generatePathName(String pathName, String operationType) {
    final path = pathName.replaceAll('{', '').replaceAll('}', '');
    return ReCase('$operationType/$path').camelCase;
  }
}
