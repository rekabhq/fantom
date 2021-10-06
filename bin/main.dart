import 'dart:io';

import 'package:fantom/fantom.dart';

Future main(List<String> args) async {
  try {
    exit(await FantomCli().run(args));
  } catch (e, stacktrace) {
    handleExceptions(e, stacktrace);
  }
}
