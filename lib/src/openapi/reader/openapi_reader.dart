import 'package:fantom/fantom.dart';
import 'package:fantom/src/openapi/model/model.dart';

class OpenApiReader {
  OpenApiReader();

  OpenApi parseOpenApiModel(Map<String, dynamic> openapi) {
    _checkVersionOf(openapi);
    return OpenApi.fromMap(openapi);
  }

  void _checkVersionOf(Map<String, dynamic> openapi) {
    if (openapi['swagger'] != null) {
      throw UnSupportedOpenApiVersionException(openapi['swagger'].toString());
    }
    if (openapi['openapi'] == null) {
      throw NotAnOpenApiFileException();
    } else if (!openapi['openapi'].toString().startsWith('3')) {
      throw UnSupportedOpenApiVersionException(openapi['openapi'].toString());
    }
  }
}
