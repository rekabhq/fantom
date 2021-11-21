import 'package:uri/uri.dart';

class MethodUriParser {
  String parseUri({
    required String pathURL,
    List<UriParam>? pathParameters,
    List<UriParam>? queryParameters,
  }) {
    // create clone form path url
    var templatePath = pathURL.toString();

    if (pathParameters != null) {
      for (final pathParam in pathParameters) {
        final char = pathParam.initChar;
        final explodeChar = pathParam.explode ? '*' : '';
        final parameterTemplate = '{$char${pathParam.name}$explodeChar}';

        templatePath = templatePath.replaceAll(
          '{${pathParam.name}}',
          parameterTemplate,
        );
      }
    }

    // {?id*,numbers*}
    if (queryParameters != null && queryParameters.isNotEmpty) {
      // initialize query string
      templatePath += '{?';

      for (var queryParam in queryParameters) {
        final explodeChar = queryParam.explode ? '*' : '';
        // add query parameter to the end of the path
        templatePath += '${queryParam.name}$explodeChar,';
      }
      // remove last comma `,` character
      templatePath = templatePath.substring(0, templatePath.length - 1);

      templatePath += '}';
    }

    final uriTemplate = UriTemplate(templatePath);

    final templateVariables = <String, dynamic>{
      if (pathParameters?.isNotEmpty ?? false)
        ...pathParameters!.toMapOfParams(),
      if (queryParameters?.isNotEmpty ?? false)
        ...queryParameters!.toMapOfParams(),
    };

    // TODO: find a way to handle spaceDelimited and pipeDelimited
    return uriTemplate.expand(templateVariables);
  }

  String parseHeader(UriParam header) {
    if (header.style != 'simple') {
      throw StateError('Only simple style is supported for header Parameters');
    }

    final explodeChar = header.explode ? '*' : '';
    final uriTemplate = UriTemplate('{${header.name}$explodeChar}');

    final templateVariables = <String, dynamic>{
      header.name: header.value,
    };

    return uriTemplate.expand(templateVariables);
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
}

class UriParam {
  UriParam._(this.name, this.value, this.style, this.explode);

  factory UriParam.object(
    String name,
    Map<String, dynamic> value,
    String style,
    bool explode,
  ) {
    return UriParam._(name, value, style, explode);
  }

  factory UriParam.array(
    String name,
    List<dynamic> value,
    String style,
    bool explode,
  ) {
    return UriParam._(name, value, style, explode);
  }

  factory UriParam.primitive(
    String name,
    dynamic value,
    String style,
  ) {
    return UriParam._(name, value, style, false);
  }

  final String name;

  final dynamic value;

  final bool explode;

  final String style;

  String get initChar {
    switch (style) {
      case 'simple':
        return '';
      case 'label':
        return '.';
      case 'matrix':
        return ';';
      case 'form':
        return '?';
      case 'spaceDelimited':
        return '?';
      case 'pipeDelimited':
        return '?';
      // TODO: add support for deepObject values
      case 'deepObject':
        throw UnimplementedError('currently we are not supporting deepObject');
      default:
        return '';
    }
  }
}

extension UriParamNumberExt on num {
  UriParam toUriParam(String name, String style, bool explode) {
    return UriParam.primitive(name, this, style);
  }
}

extension UriParamStringExt on String {
  UriParam toUriParam(String name, String style, bool explode) {
    return UriParam.primitive(name, this, style);
  }
}

extension UriParamBoolExt on bool {
  UriParam toUriParam(String name, String style, bool explode) {
    return UriParam.primitive(name, this, style);
  }
}

extension UriParamListExt on List {
  UriParam toUriParam(String name, String style, bool explode) {
    return UriParam.array(name, this, style, explode);
  }
}

extension UriParamMapExt on Map<String, dynamic> {
  UriParam toUriParam(String name, String style, bool explode) {
    return UriParam.object(name, this, style, explode);
  }
}

extension UriListExt on List<UriParam> {
  Map<String, dynamic> toMapOfParams() {
    var map = <String, dynamic>{};
    for (var param in this) {
      map[param.name] = param.value;
    }
    return map;
  }
}
