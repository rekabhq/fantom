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
      methodName = '$methodName$counter';
      counter++;
    }

    return methodName;
  }

  String _generatePathName(String pathName, String operationType) {
    return ReCase('$operationType/$pathName').camelCase;
  }
}
