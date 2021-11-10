@Timeout(Duration(minutes: 1))
import 'package:fantom/src/generator/name/method_name_generator.dart';
import 'package:fantom/src/generator/name/utils.dart';
import 'package:test/test.dart';

void main() {
  group('MethodNameGenerator.generateName method:', () {
    late MethodNameGenerator methodNameGenerator;

    setUp(() => methodNameGenerator = MethodNameGenerator({}));

    test(
      'test generate method name with sample path',
      () async {
        final path = 'test/path/to/file';
        final OperationDetail detail = OperationDetail(
          path: path,
          operationType: 'get',
        );

        final resultName = methodNameGenerator.generateUniqueName(detail);

        expect(resultName, equals('getTestPathToFile'));
      },
    );

    test(
      'test generate method name with single path param',
      () async {
        final path = 'test/path/{to}/file';
        final OperationDetail detail = OperationDetail(
          path: path,
          operationType: 'get',
        );

        final resultName = methodNameGenerator.generateUniqueName(detail);

        expect(resultName, equals('getTestPathToFile'));
      },
    );

    test(
      'test generate method name with dotted path',
      () async {
        final path = 'test/path/{to}/file.format';
        final OperationDetail detail = OperationDetail(
          path: path,
          operationType: 'get',
        );

        final resultName = methodNameGenerator.generateUniqueName(detail);

        expect(resultName, equals('getTestPathToFileFormat'));
      },
    );

    test(
      'test generate method name with dotted path param',
      () async {
        final path = 'test/path/{to}/file.{format}';
        final OperationDetail detail = OperationDetail(
          path: path,
          operationType: 'get',
        );

        final resultName = methodNameGenerator.generateUniqueName(detail);

        expect(resultName, equals('getTestPathToFileFormat'));
      },
    );

    test(
      'test generate method name with operationID',
      () async {
        final path = 'test/path/{to}/file.{format}';
        final OperationDetail detail = OperationDetail(
            path: path, operationType: 'get', operationId: 'test_path_file');

        final resultName = methodNameGenerator.generateUniqueName(detail);

        expect(resultName, equals('testPathFile'));
      },
    );
  });

  group('MethodNameGenerator.generateUniqueName method:', () {
    late MethodNameGenerator methodNameGenerator;

    setUp(() => methodNameGenerator = MethodNameGenerator());

    test(
      'test generateUniqueName method with sample path',
      () async {
        final history = <String>[];

        final path = 'test/path/to/file';
        final OperationDetail detail = OperationDetail(
          path: path,
          operationType: 'get',
        );

        final resultName = methodNameGenerator.generateUniqueName(detail);

        history.add(resultName);

        final resultName2 = methodNameGenerator.generateUniqueName(detail);

        expect(resultName2, equals('getTestPathToFile2'));
      },
    );

    test(
      'test generateUniqueName method with sample path in 4 iteration',
      () async {
        final history = <String>[];

        final path = 'test/path/to/file';
        final OperationDetail detail = OperationDetail(
          path: path,
          operationType: 'get',
        );

        var resultName = '';
        for (var i = 0; i < 4; i++) {
          resultName = methodNameGenerator.generateUniqueName(detail);
          history.add(resultName);
        }

        expect(resultName, equals('getTestPathToFile4'));
      },
    );

    test(
      'test generateUniqueName method with operationId in 4 iteration',
      () async {
        final history = <String>[];

        final path = 'test/path/to/file';
        final OperationDetail detail = OperationDetail(
          path: path,
          operationType: 'get',
          operationId: 'get_operation',
        );

        var resultName = '';
        for (var i = 0; i < 4; i++) {
          resultName = methodNameGenerator.generateUniqueName(detail);
          history.add(resultName);
        }

        expect(resultName, equals('getOperation4'));
      },
    );
  });
}
