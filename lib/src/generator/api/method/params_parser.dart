import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/reader/model/model.dart';

/// should create a metaData object (which is yet to be decided what it is) that explains everything about the parameters
/// of this method in a way that it can be easily used to generate parameters for our method
///
class MethodParamsParser {
  List<GeneratedParameterComponent> parseParams(
    List<Referenceable<Parameter>> operationParameters, {
    List<Referenceable<Parameter>>? pathParameters,
  }) {

    return [];
  }

  List<GeneratedParameterComponent> _parsePureParams(
    List<Parameter> operationParameters, {
    List<Parameter>? pathParameters,
  }) {
    final uniqueParams = <Parameter>[...operationParameters];

    /// we are finding the path parameters that now override by the operation params and
    /// add them to [uniqueParams] list
    if (pathParameters != null) {
      for (var pathItem in pathParameters) {
        bool isOverridden = false;
        for (var uniqueItem in uniqueParams) {
          if (_isParamOverridden(pathItem, uniqueItem)) {
            isOverridden = true;
            break;
          }
        }

        if (!isOverridden) {
          uniqueParams.add(pathItem);
        }
      }
    }

    return [];
  }

  bool _isParamOverridden(Parameter operation, Parameter path) {
    return operation.name == path.name && operation.location == path.location;
  }
}
