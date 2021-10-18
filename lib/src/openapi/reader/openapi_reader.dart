import 'package:fantom/fantom.dart';
import 'package:fantom/src/openapi/model/model.dart';
import 'package:fantom/src/utils/constants.dart';
import 'package:version/version.dart';

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
    } else if (!_isOpenApiVersionSupported(openapi['openapi'].toString())) {
      throw UnSupportedOpenApiVersionException(openapi['openapi'].toString());
    }
  }

  bool _isOpenApiVersionSupported(String version) {
    final parsedVersion = Version.parse(version);
    return parsedVersion.compareTo(kMinOpenapiSupportedVersion) >= 0;
  }
}
