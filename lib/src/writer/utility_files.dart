import 'dart:io';

import 'package:fantom/src/writer/generatbale_file.dart';

final allUtilityFiles = [
  GeneratableFile.fromFile(
    File('lib/src/generator/schema/copy.dart'),
    fileName: 'equatbles.dart',
  ),
  GeneratableFile.fromFile(
    File('lib/src/generator/api/method/uri_parser.dart'),
    fileName: 'uri_parser.dart',
  ),
];
