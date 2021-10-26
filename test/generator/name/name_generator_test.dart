@Timeout(Duration(minutes: 1))
import 'package:fantom/src/generator/name/method_name_generator.dart';
import 'package:fantom/src/generator/name/name_generator.dart';
import 'package:fantom/src/generator/name/utils.dart';
import 'package:test/test.dart';

void main() {
  group('NameGenerator.generateParameterName method:', () {
    late NameGenerator nameGenerator;

    setUp(() => nameGenerator = NameGenerator(MethodNameGenerator()));

    test(
      'test generateParameterName',
      () async {
        final ParameterDetails detail = ParameterDetails(
          name: 'details',
          methodName: 'getUser',
        );

        final resultName = nameGenerator.generateParameterName(detail);

        expect(resultName, equals('GetUserDetails'));
      },
    );
  });
}
