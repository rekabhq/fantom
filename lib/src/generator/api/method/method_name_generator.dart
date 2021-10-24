import 'package:fantom/src/generator/model/operation_detail.dart';
import 'package:recase/recase.dart';

class MethodNameGenerator {
  String generateName(OperationDetail operationDetail) {
    if (operationDetail.operationId?.isNotEmpty ?? false) {
      return ReCase(operationDetail.operationId!).camelCase;
    } else {
      return _generatePathName(
        operationDetail.path,
        operationDetail.operationType,
      );
    }
  }

  String generateUniqueName(
    OperationDetail operationDetail,
    List<String> history,
  ) {
    String methodName = generateName(operationDetail);
    int counter = 1;

    while (history.contains(methodName)) {
      if (methodName.endsWith(counter.toString())) {
        methodName = methodName.substring(
          0,
          methodName.length - counter.toString().length,
        );
      }

      counter++;

      methodName = '$methodName$counter';
    }

    return methodName;
  }

  String _generatePathName(String pathName, String operationType) {
    final path = pathName.replaceAll('{', '').replaceAll('}', '');
    return ReCase('$operationType/$path').camelCase;
  }
}
