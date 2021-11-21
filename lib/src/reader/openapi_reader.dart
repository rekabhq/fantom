import 'package:fantom/fantom.dart';
import 'package:fantom/src/cli/config/fantom_config.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/constants.dart';
import 'package:fantom/src/utils/logger.dart';
import 'package:version/version.dart';
import 'package:fantom/src/utils/extensions.dart';

class OpenApiReader {
  final Map<String, dynamic> openapi;
  final FantomConfig config;

  OpenApiReader({required this.openapi, required this.config});

  OpenApi parseOpenApiModel() {
    _checkVersionOf(openapi);
    _removeExcludedComponents(openapi);
    _removeExcludedPaths(openapi);
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

  void _removeExcludedComponents(Map<String, dynamic> openapi) {
    for (var component in config.excludedComponents) {
      openapi.removeItemInNestedMapsWithKeys(component.split('/'));
    }
  }

  void _removeExcludedPaths(Map<String, dynamic> openapi) {
    for (var entry in config.excludedPaths.paths.entries) {
      final path = entry.key;
      final operations = entry.value;
      if (operations.isEmpty) {
        // delete all operations in that path if no operations is defined for excluding
        openapi.removeItemInNestedMapsWithKeys(['paths', path]);
      } else {
        // delete only operations defined for excluding
        Map<String, dynamic>? pathObject = openapi['paths'][path];
        if (pathObject != null) {
          for (var operation in operations) {
            Log.debug('\nremoving $operation from $pathObject\n\n');
            pathObject.remove(operation);
          }
        }
        Log.debug('result is $pathObject');
      }
    }
  }
}
