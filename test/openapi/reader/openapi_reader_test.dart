@Timeout(Duration(minutes: 1))
// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:fantom/fantom.dart';
import 'package:fantom/src/cli/config/exclude_models.dart';
import 'package:fantom/src/cli/config/fantom_config.dart';
import 'package:fantom/src/cli/options_values.dart';
import 'package:fantom/src/utils/extensions.dart';
import 'package:fantom/src/reader/openapi_reader.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  group('OpenApiReader:', () {
    late Map<String, dynamic> openapiMap;
    late Map<String, dynamic> openapiMapWithUnsupportedVersion;
    late Map<String, dynamic> swaggerMap;
    late Map<String, dynamic> notAnOpenapiMap = {};
    final config = FantomConfig(
      path: '',
      apiMethodReturnType: MethodReturnType.result,
      excludedComponents: [],
      excludedPaths: ExcludedPaths.fromFantomConfigValues([]),
    );

    setUpAll(() async {
      openapiMap =
          await readJsonOrYamlFile(File('openapi_files/petstore.openapi.yaml'));
      swaggerMap = openapiMap.clone();
      swaggerMap.remove('openapi');
      swaggerMap['swagger'] = '2.0.0';
      openapiMapWithUnsupportedVersion = openapiMap.clone();
      openapiMapWithUnsupportedVersion['openapi'] = '2.0.0';
    });

    test(
      'should read an openapi map and returns the OpenApi model object without errors',
      () async {
        //with
        var openapiModel = OpenApiReader(openapi: openapiMap, config: config)
            .parseOpenApiModel();
        // tests for OpenApi model object are in the corresponsing folder in this project
      },
    );

    test(
      'should throw exception because swagger is not supported (swagger is openapi v2)',
      () async {
        //with
        expect(
          () => OpenApiReader(openapi: swaggerMap, config: config)
              .parseOpenApiModel(),
          throwsA(isA<UnSupportedOpenApiVersionException>()),
        );
      },
    );

    test(
      'should throw exception because openapi version below 3.0.0 is not supported',
      () async {
        //with
        expect(
          () => OpenApiReader(
            openapi: openapiMapWithUnsupportedVersion,
            config: config,
          ).parseOpenApiModel(),
          throwsA(isA<UnSupportedOpenApiVersionException>()),
        );
      },
    );

    test(
      'should throw exception since provided map does not contain an openapi sepecification',
      () async {
        //with
        expect(
          () => OpenApiReader(
            openapi: notAnOpenapiMap,
            config: config,
          ).parseOpenApiModel(),
          throwsA(isA<InvalidOpenApiFileException>()),
        );
      },
    );
  });
}
