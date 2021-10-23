import 'package:fantom/src/generator/api/method/api_method_generator.dart';
import 'package:fantom/src/openapi/model/model.dart';

class ApiClassGenerator {
  final OpenApi openApi;
  final ApiMethodGenerator apiMethodGenerator;

  ApiClassGenerator({
    required this.openApi,
    required this.apiMethodGenerator,
  });
}
