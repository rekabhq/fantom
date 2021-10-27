import 'package:uri/uri.dart';

class MethodUriParser {
  Uri parseUri({
    required String baseURL,
    required String pathURL,
    required List<UriParam> pathParameters,
    required List<UriParam> queryParameters,
  }) {
    var fixedUrls = fixBaseUrlAndPath(baseURL, pathURL);
    var baseUrl = fixedUrls.first;
    var path = fixedUrls.last;
    final baseUri = Uri.parse(baseUrl);
    final pathUriTemplate = UriTemplate(path);
    final serializedPath = pathUriTemplate.expand(
      pathParameters.toMapOfParams(),
    );
    var serializedPathUri = Uri.parse(serializedPath);
    if (queryParameters.isNotEmpty) {
      serializedPathUri = serializedPathUri.replace(
        queryParameters: queryParameters.toMapOfParams(),
      );
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

class UriParam {
  UriParam._(String name, dynamic value, bool explode) {
    if (explode && !name.endsWith('*')) {
      name = '$name*';
    }
    _name = name;
    _value = value;
  }

  late String _name;

  late dynamic _value;

  String get name => _name;

  dynamic get value => _value;

  factory UriParam.object(
    String name,
    Map<String, dynamic> value,
    bool explode,
  ) {
    return UriParam._(name, value, explode);
  }

  factory UriParam.array(String name, List<dynamic> value, bool explode) {
    return UriParam._(name, value, explode);
  }

  factory UriParam.primitive(String name, dynamic value) {
    return UriParam._(name, value, false);
  }
}

extension UriParamListExt on List<UriParam> {
  Map<String, dynamic> toMapOfParams() {
    var map = <String, dynamic>{};
    for (var param in this) {
      map[param.name] = param.value;
    }
    return map;
  }
}
