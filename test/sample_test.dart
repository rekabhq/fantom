@Timeout(Duration(minutes: 1))
import 'package:test/test.dart';

void main() {
  group('int', () {
    test('test', () {
      expect(11.remainder(3), equals(2));
    });
  });
}
