@Timeout(Duration(minutes: 1))
import 'dart:convert';
import 'dart:isolate';

import 'package:test/test.dart';

void main() {
  group('just testin around', () {
    test('test', () async {
      final started = DateTime.now();
      // test 1
      final test = TestIsolates(fakeJson);
      final names = await test.parseResults();
      print(names);
      final test1Time = DateTime.now();
      final time = test1Time.difference(started).inMilliseconds;
      print('test took $time milliseconds');
      // test 2
      final test2 = TestIsolates(fakeJson);
      final names2 = await test2.parseResults();
      print(names2);
      final test2Time = DateTime.now();
      final time2 = test2Time.difference(test1Time).inMilliseconds;
      print('test 2 took $time2 milliseconds');
      // test 3
      final test3 = TestIsolates(fakeJson);
      final names3 = await test3.parseResults();
      print(names3);
      final test3Time = DateTime.now();
      final time3 = test3Time.difference(test2Time).inMilliseconds;
      print('test 3 took $time3 milliseconds');
      // test 4
      final test4 = TestIsolates(fakeJson);
      final names4 = await test4.parseResults();
      print(names4);
      final test4Time = DateTime.now();
      final time4 = test4Time.difference(test3Time).inMilliseconds;
      print('test 4 took $time4 milliseconds');
    });
  });
}

class TestIsolates {
  TestIsolates(this.encodedJson);
  final String encodedJson;

  Future<List<String>> parseResults() async {
    final p = ReceivePort();
    await Isolate.spawn(_doJob, p.sendPort);
    return await p.first;
  }

  Future<void> _doJob(SendPort p) async {
    final jsonData = jsonDecode(encodedJson);
    final resultsJson = jsonData['names'] as List<dynamic>;
    final results = resultsJson.map((e) => e.toString()).toList();
    Isolate.exit(p, results);
  }
}

final fakeJson = jsonEncode({
  'names': [
    'alireza',
    'payam',
    're rey',
    'momir',
  ]
});
