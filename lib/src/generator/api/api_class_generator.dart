import 'package:fantom/src/generator/api/method/api_method_generator.dart';
import 'package:fantom/src/reader/model/model.dart';
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


    }
    ''',
      fileName: 'api.dart',
    );
  }
}
