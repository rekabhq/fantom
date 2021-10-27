import 'package:fantom/fantom.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/constants.dart';
import 'package:version/version.dart';

class OpenApiReader {
  static OpenApi parseOpenApiModel(Map<String, dynamic> openapi) {
    _checkVersionOf(openapi);
    return OpenApi.fromMap(openapi);
  }

  static void _checkVersionOf(Map<String, dynamic> openapi) {
    if (openapi['swagger'] != null) {
      throw UnSupportedOpenApiVersionException(openapi['swagger'].toString());
    }
    if (openapi['openapi'] == null) {
      throw InvalidOpenApiFileException();
    } else if (!_isOpenApiVersionSupported(openapi['openapi'].toString())) {
      throw UnSupportedOpenApiVersionException(openapi['openapi'].toString());
    }
  }

  static bool _isOpenApiVersionSupported(String version) {
    final parsedVersion = Version.parse(version);
    return parsedVersion.compareTo(kMinOpenapiSupportedVersion) >= 0;
  }

  static bool _isValidVersion(Version version) {
    return version.compareTo(kMinOpenapiSupportedVersion) >= 0 &&
        version.compareTo(kMaxOpenapiSupportedVersion) < 0;
  }
}
