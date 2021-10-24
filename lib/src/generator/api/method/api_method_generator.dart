import 'package:fantom/src/generator/api/method/params_parser.dart';
import 'package:fantom/src/generator/api/method/response_parser.dart';
import 'package:fantom/src/reader/model/model.dart';

class ApiMethodGenerator {
  final OpenApi openApi;
  final MethodParamsParser methodParamsParser;
  final MethodResponseParser methodResponseParser;

  ApiMethodGenerator({
    required this.openApi,
    required this.methodParamsParser,
    required this.methodResponseParser,
  });

  String generateMethod(Operation operation) {
    //TODO: shold use [methodParamsParser] & [methodResponseParser] to find out what are the responses and parameters
    // for this api method and then create a body accordingly
    // then return the entire method definition as a String

    return '''
    User getUserById(int id){
      
    }
    ''';
  }
}
