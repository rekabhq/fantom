import 'dart:io';

import 'package:fantom/fantom.dart';

Future main(List<String> args) async {
  exit(await FantomCli.createDefaultInstance().run(args));
}
