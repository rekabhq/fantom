import 'package:fantom/src/generator/api/method/params_parser.dart';
import 'package:fantom/src/generator/api/method/response_parser.dart';
import 'package:fantom/src/openapi/model/model.dart';

class ApiMethodGenerator {
  final OpenApi openApi;
  final ParamsParser paramsParser;
  final ResponseParser responseParser;

  ApiMethodGenerator({
    required this.openApi,
    required this.paramsParser,
    required this.responseParser,
  });
}
