@Timeout(Duration(minutes: 1))
// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:fantom/fantom.dart';
import 'package:fantom/src/utils/extensions/extensions.dart';
import 'package:fantom/src/reader/openapi_reader.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:test/test.dart';

void main() {
  group('OpenApiReader:', () {
    Map<String, dynamic>? openapiMap;
    Map<String, dynamic>? openapiMapWithUnsupportedVersion;
    Map<String, dynamic>? swaggerMap;
    Map<String, dynamic>? notAnOpenapiMap = {};

    setUpAll(() async {
      openapiMap =
          await readJsonOrYamlFile(File('test/utils/petstore.openapi.yaml'));
      swaggerMap = openapiMap!.clone();
      swaggerMap!.remove('openapi');
      swaggerMap!['swagger'] = '2.0.0';
      openapiMapWithUnsupportedVersion = openapiMap!.clone();
      openapiMapWithUnsupportedVersion!['openapi'] = '2.0.0';
    });

    tearDownAll(() {
      openapiMap = null;
    });

    test(
      'should read an openapi map and returns the OpenApi model object without errors',
      () async {
        //with
        var openapiModel = OpenApiReader.parseOpenApiModel(openapiMap!);
        // tests for OpenApi model object are in the corresponsing folder in this project
      },
    );

    test(
      'should throw exception because swagger is not supported (swagger is openapi v2)',
      () async {
        //with
        expect(
          () => OpenApiReader.parseOpenApiModel(swaggerMap!),
          throwsA(isA<UnSupportedOpenApiVersionException>()),
        );
      },
    );

    test(
      'should throw exception because openapi version below 3.0.0 is not supported',
      () async {
        //with
        expect(
          () => OpenApiReader.parseOpenApiModel(openapiMapWithUnsupportedVersion!),
          throwsA(isA<UnSupportedOpenApiVersionException>()),
        );
      },
    );

    test(
      'should throw exception since provided map does not contain an openapi sepecification',
      () async {
        //with
        expect(
          () => OpenApiReader.parseOpenApiModel(notAnOpenapiMap),
          throwsA(isA<InvalidOpenApiFileException>()),
        );
      },
    );
  });
}
