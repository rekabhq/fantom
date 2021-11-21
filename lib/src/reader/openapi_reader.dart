import 'package:fantom/fantom.dart';
import 'package:fantom/src/cli/config/fantom_config.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/constants.dart';
import 'package:version/version.dart';

class OpenApiReader {
  final Map<String, dynamic> openapi;
  final FantomConfig config;

  OpenApiReader({required this.openapi, required this.config});

  OpenApi parseOpenApiModel() {
    _checkVersionOf(openapi);
    _excludePathsAndComponents(openapi);
    return OpenApi.fromMap(openapi);
  }

  void _checkVersionOf(Map<String, dynamic> openapi) {
    if (openapi['swagger'] != null) {
      throw UnSupportedOpenApiVersionException(openapi['swagger'].toString());
    }
    if (openapi['openapi'] == null) {
      throw InvalidOpenApiFileException();
    } else if (!_isOpenApiVersionSupported(openapi['openapi'].toString())) {
      throw UnSupportedOpenApiVersionException(openapi['openapi'].toString());
    }
  }

  bool _isOpenApiVersionSupported(String version) {
    final parsedVersion = Version.parse(version);
    return _isValidVersion(parsedVersion);
  }

  bool _isValidVersion(Version version) {
    return version.compareTo(kMinOpenapiSupportedVersion) >= 0 &&
        version.compareTo(kMaxOpenapiSupportedVersion) < 0;
  }

  void _excludePathsAndComponents(Map<String, dynamic> openapi) {}
}
