import 'package:uri/uri.dart';

class MethodUriParser {
  Uri parseUri(
    String baseURL,
    String pathURL,
    Map<String, List<String>> pathParameters,
    Map<String, List<String>> queryParameters,
  ) {
    var fixedUrls = fixBaseUrlAndPath(baseURL, pathURL);
    var baseUrl = fixedUrls.first;
    var path = fixedUrls.last;
    final baseUri = Uri.parse(baseUrl);
    final pathUriTemplate = UriTemplate(path);
    final serializedPath = pathUriTemplate.expand(pathParameters);
    var serializedPathUri = Uri.parse(serializedPath);
    if (queryParameters.isNotEmpty) {
      serializedPathUri =
          serializedPathUri.replace(queryParameters: queryParameters);
    }
    return baseUri.resolveUri(serializedPathUri);
  }

  List<String> fixBaseUrlAndPath(String baseUrl, String path) {
    if (baseUrl.endsWith('/') && path.startsWith('/')) {
      print('both have /');
      return [baseUrl.substring(0, baseUrl.length - 1), path];
    } else if (!baseUrl.endsWith('/') && !path.startsWith('/')) {
      print('none have /');
      return ['$baseUrl/', path];
    } else {
      return [baseUrl, path];
    }
  }
}
