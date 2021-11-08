@Timeout(Duration(minutes: 1))
import 'package:fantom/src/generator/api/method/parameter_serializer.dart';
import 'package:test/test.dart';

void main() {
  group('SimpleSerializer.serialize method - Simple tests:', () {
    final simpleSerializer = SimpleSerializer();

    test(
      'test simple serializer with primitive parameter',
      () async {
        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: 4,
          ),
          equals('4'),
        );

        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: 'Test',
          ),
          equals('Test'),
        );

        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: true,
          ),
          equals('true'),
        );
      },
    );
    test(
      'test simple serializer with primitive parameter - explode',
      () async {
        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: 4,
            explode: true,
          ),
          equals('4'),
        );

        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: 'Test',
            explode: true,
          ),
          equals('Test'),
        );

        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: true,
            explode: true,
          ),
          equals('true'),
        );
      },
    );

    test(
      'test simple serializer with array parameter',
      () async {
        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: [3, 4, 5],
          ),
          equals('3,4,5'),
        );

        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: [3, '4', 5],
          ),
          equals('3,4,5'),
        );

        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: [3, true, 'hi'],
          ),
          equals('3,true,hi'),
        );
      },
    );

    test(
      'test simple serializer with array parameter - explode',
      () async {
        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: [3, 4, 5],
            explode: true,
          ),
          equals('3,4,5'),
        );

        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: [3, '4', 5],
            explode: true,
          ),
          equals('3,4,5'),
        );

        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: [3, true, 'hi'],
            explode: true,
          ),
          equals('3,true,hi'),
        );
      },
    );

    test(
      'test simple serializer with object parameter',
      () async {
        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: {
              "role": "admin",
              "firstName": "Alex",
            },
          ),
          equals('role,admin,firstName,Alex'),
        );

        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: {
              'a': 1,
              'b': '2',
              'c': true,
            },
          ),
          equals('a,1,b,2,c,true'),
        );
      },
    );

    test(
      'test simple serializer with object parameter - explode',
      () async {
        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: {
              "role": "admin",
              "firstName": "Alex",
            },
            explode: true,
          ),
          equals('role=admin,firstName=Alex'),
        );

        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: {
              'a': 1,
              'b': '2',
              'c': true,
            },
            explode: true,
          ),
          equals('a=1,b=2,c=true'),
        );
      },
    );
  });

  group('SimpleSerializer.serialize method - Nested tests:', () {
    final simpleSerializer = SimpleSerializer();
    test(
      'test simple serializer with nested array parameter',
      () async {
        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: [
              {'a': '1'},
              {'b': '2'},
              5,
              [true, false],
            ],
          ),
          equals('a,1,b,2,5,true,false'),
        );
        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: [
              {'a': '1'},
              {'b': '2'},
              5,
              [true, false],
            ],
            explode: true,
          ),
          equals('a=1,b=2,5,true,false'),
        );
      },
    );

    test(
      'test simple serializer with nested object parameter',
      () async {
        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: {
              "role": ["admin", "user"],
              "firstName": 'Ali',
              'married': false,
              "date": {
                "day": "Monday",
                "month": "January",
                "year": 2020,
              },
            },
          ),
          equals(
              'role,admin,user,firstName,Ali,married,false,date,day,Monday,month,January,year,2020'),
        );
        expect(
          simpleSerializer.serialize(
            parameter: 'parameter',
            value: {
              "role": ["admin", "user"],
              "firstName": 'Ali',
              "date": {
                "day": "Monday",
                "month": "January",
                "year": 2020,
              },
            },
            explode: true,
          ),
          equals(
              'role=admin,user,firstName=Ali,date=day=Monday,month=January,year=2020'),
        );
      },
    );
  });
}
