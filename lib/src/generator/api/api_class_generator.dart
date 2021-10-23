import 'package:fantom/src/generator/api/method/api_method_generator.dart';
import 'package:fantom/src/openapi/model/model.dart';
import 'package:fantom/src/writer/file_writer.dart';

class ApiClassGenerator {
  final OpenApi openApi;
  final ApiMethodGenerator apiMethodGenerator;

  ApiClassGenerator({
    required this.openApi,
    required this.apiMethodGenerator,
  });

  GeneratableFile generate() {
    return GeneratableFile(
      fileContent: '''
    class FantomApi {
      Dio dio;

      constructor



      TODO: use apiMethodGenerator to generate methods of this FantomApi class for each operation from openApi model object



    }
    ''',
      fileName: 'api.dart',
    );
  }
}
