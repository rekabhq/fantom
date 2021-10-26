import 'package:fantom/src/generator/model/operation_detail.dart';
import 'package:fantom/src/generator/name/method_name_generator.dart';

class NameGenerator {
  final MethodNameGenerator _methodNameGenerator;

  const NameGenerator(this._methodNameGenerator);

  String generateMethodName(OperationDetail operationDetail) {
    return _methodNameGenerator.generateUniqueName(operationDetail);
  }
}
