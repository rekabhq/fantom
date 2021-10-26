import 'package:fantom/src/generator/api/method/method_name_generator.dart';
import 'package:fantom/src/generator/api/method/params_parser.dart';
import 'package:fantom/src/generator/api/method/response_parser.dart';
import 'package:fantom/src/generator/model/operation_detail.dart';
import 'package:fantom/src/reader/model/model.dart';

// ignore_for_file: unused_element
class ApiMethodGenerator {
  final OpenApi openApi;
  final MethodParamsParser methodParamsParser;
  final MethodResponseParser methodResponseParser;

  ApiMethodGenerator({
    required this.openApi,
    required this.methodParamsParser,
    required this.methodResponseParser,
  });

  String generateMethods() {
    if (openApi.paths?.paths.isEmpty ?? true) return '';

    // helper class for generating names
    final nameGenerator = MethodNameGenerator();

    // buffer to store generated data
    final buffer = StringBuffer();

    // this is a container that help ous to generate and store unique names for our methods
    final methodNameHistory = <OperationDetail, String>{};

    // iterating over paths
    for (final path in openApi.paths!.paths.entries) {
      final pathParams = path.value.parameters;

      if (path.value.operations.isNotEmpty) {
        buffer.writeln('//${path.key}');
      }

      // iterating over operations of the path
      for (final operation in path.value.operations.entries) {
        final operationDetail = OperationDetail(
          path: path.key,
          operationType: operation.key,
          operationId: operation.value.operationId,
        );

        final methodName = nameGenerator.generateUniqueName(
          operationDetail,
          methodNameHistory.values.toList(),
        );

        methodNameHistory[operationDetail] = methodName;

        buffer.writeln(
          _generateOperation(
            methodName,
            operation,
            pathParams,
          ),
        );
      }
    }

    return buffer.toString();
  }

  String _generateOperation(
    String methodName,
    MapEntry<String, Operation> operation,
    List<Referenceable<Parameter>>? pathParams,
  ) {
    //TODO: all methods should have an optional parameter named contentType

    //TODO: get information about parameter,body and

    // Steps:
    // -------
    // 1. generate method return type
    // ->"Future"<- methodName(params)
    // 2. generate method name
    // Future ->"methodName"<- (params)
    // 3. generate method parameters
    // Future methodName ->"(params)"<-
    // -------
    // 4. generate parsed path - get paths from params and parse them
    // final parsedPath = _parsePath(pathParams, path);
    // 5. generate query parameters
    // final queryParams = {'id': '123' , 'name': 'John'};
    // 6. generate header parameters
    // final headerParams = {'accept': 'json'};
    // 7. generate body parameters
    // final bodyParams = _parseBody(bodyParam);
    // -------
    // 8. create request option for headers and content type
    // final option =  Options(
    //  headers = headerParams,
    //  contentType = contentType,
    // );
    // 9. generate request
    // final response = await dio.request(
    //  parsedPath,
    //  queryParameters: queryParams,
    //  options: option,
    //  data: bodyParams,
    // );
    // 10. generate evaluated response
    // we should think about this
    // return evaluateResponse(response);
    //

    return """

    """;
  }

  //TODO(payam): update response of this method
  String _generateParameters(
    List<Referenceable<Parameter>>? operationParams,
    List<Referenceable<Parameter>>? pathParams,
  ) {
    return """

    """;
  }

  //TODO(payam): update response of this method
  String _generateRequestBody(
    Referenceable<RequestBody>? requestBody,
  ) {
    return """

    """;
  }

  //TODO(payam): update response of this method
  String _generateResponses(Responses responses) {
    return """

    """;
  }
}
