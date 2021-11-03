import 'package:fantom/src/writer/file_writer.dart';

const allUtilityFiles = [
  GeneratableFile(
    fileName: 'uri_parser.dart',
    fileContent: r'''
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

    for (var pathParam in pathParameters) {
      if (pathParam.explode) {
        final unExplodedHolder = '{' + pathParam.name + '}';
        final explodedHolder = '{' + pathParam.name + '*}';
        if (path.split('?').first.contains(unExplodedHolder)) {
          path = path.replaceAll(unExplodedHolder, explodedHolder);
        }
      }
    }

    final baseUri = Uri.parse(baseUrl);
    final pathUriTemplate = UriTemplate(path);
    final serializedPath = pathUriTemplate.expand(
      pathParameters.toMapOfParams(),
    );
    var serializedPathUri = Uri.parse(serializedPath);
    if (queryParameters.isNotEmpty) {
      serializedPathUri = serializedPathUri.replace(
        queryParameters: _uriQeriesFrom(queryParameters),
      );
    }
    return baseUri.resolveUri(serializedPathUri);
  }

  List<String> fixBaseUrlAndPath(String baseUrl, String path) {
    if (baseUrl.endsWith('/') && path.startsWith('/')) {
      return [baseUrl.substring(0, baseUrl.length - 1), path];
    } else if (!baseUrl.endsWith('/') && !path.startsWith('/')) {
      return ['$baseUrl/', path];
    } else {
      return [baseUrl, path];
    }
  }

  Map<String, Iterable<String>> _uriQeriesFrom(List<UriParam> queryParameters) {
    var queries = <String, Iterable<String>>{};
    for (var param in queryParameters) {
      var key = param.name;
      var value = param.value;
      if (value is Map) {
        for (var entry in value.entries) {
          var entryKey = entry.key.toString();
          var entryValue = entry.value.toString();
          queries[entryKey] = [entryValue];
        }
      } else if (value is List) {
        queries[key] = value.map((e) => e.toString()).toList();
      } else {
        queries[key] = [value.toString()];
      }
    }
    return queries;
  }
}

class UriParam {
  UriParam._(this.name, this.value, this.explode);

  final String name;

  final dynamic value;

  final bool explode;

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
    ''',
  ),
];
