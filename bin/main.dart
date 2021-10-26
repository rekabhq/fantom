import 'dart:io';

import 'package:fantom/fantom.dart';

Future main(List<String> args) async {
  var exitCode = await FantomCli.createDefaultInstance().run(args);
  print('\nexited with code $exitCode');
  exit(exitCode);
}
