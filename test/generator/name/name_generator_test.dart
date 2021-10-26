@Timeout(Duration(minutes: 1))
import 'package:fantom/src/generator/name/method_name_generator.dart';
import 'package:fantom/src/generator/name/name_generator.dart';
import 'package:fantom/src/generator/name/utils.dart';
import 'package:test/test.dart';

void main() {
  group('NameGenerator.generateParameterName method', () {
    late NameGenerator nameGenerator;

    setUp(() => nameGenerator = NameGenerator(MethodNameGenerator()));

    test(
      'test generateParameterName method',
      () async {
        final details = ParameterDetails(
          name: 'details',
          methodName: 'getUser',
        );

        final resultName = nameGenerator.generateParameterName(details);

        expect(resultName, equals('GetUserDetails'));
      },
    );
  });

  group('NameGenerator.generateParameterName method', () {
    late NameGenerator nameGenerator;

    setUp(() => nameGenerator = NameGenerator(MethodNameGenerator()));

    test(
      'test generateParameterName method',
      () async {
        final details = ParameterDetails(
          name: 'details',
          methodName: 'getUser',
        );

        final resultName = nameGenerator.generateParameterName(details);

        expect(resultName, equals('GetUserDetails'));
      },
    );

    test(
      'test generateRequestBodyName method',
      () async {
        final details = RequestBodyDetails(
          methodName: 'updateUser',
          contentType: 'application/json',
        );

        final resultName = nameGenerator.generateRequestBodyName(details);

        expect(resultName, equals('UpdateUserJsonBody'));
      },
    );

    test(
      'test generateRequestBodyName method',
      () async {
        final details = RequestBodyDetails(
          methodName: 'updateUser',
          contentType: 'application/xml',
        );

        final resultName = nameGenerator.generateRequestBodyName(details);

        expect(resultName, equals('UpdateUserXmlBody'));
      },
    );

    test(
      'test generateRequestBodyName method',
      () async {
        final details = RequestBodyDetails(
          methodName: 'updateUser',
          contentType: 'text/plain',
        );

        final resultName = nameGenerator.generateRequestBodyName(details);

        expect(resultName, equals('UpdateUserTextPlainBody'));
      },
    );

    test(
      'test generateRequestBodyName method',
      () async {
        final details = RequestBodyDetails(
          methodName: 'updateUser',
          contentType: 'application/x-www-form-urlencoded',
        );

        final resultName = nameGenerator.generateRequestBodyName(details);

        expect(resultName, equals('UpdateUserFormDataBody'));
      },
    );

    test(
      'test generateRequestBodyName method',
      () async {
        final details = RequestBodyDetails(
          methodName: 'updateUser',
          contentType: 'multipart/form-data',
        );

        final resultName = nameGenerator.generateRequestBodyName(details);

        expect(resultName, equals('UpdateUserMultipartBody'));
      },
    );
  });
}
