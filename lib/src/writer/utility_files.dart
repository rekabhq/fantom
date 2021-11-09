import 'dart:io';

import 'package:fantom/src/writer/file_writer.dart';

final allUtilityFiles = [
  GeneratableFile(
    fileName: 'optional.dart',
    fileContent: r'''
class Optional<T> {
  final T value;

  const Optional(this.value);
}    
    ''',
  ),
  GeneratableFile.fromFile(
    File('lib/src/generator/api/method/uri_parser.dart'),
    fileName: 'uri_parser.dart',
  ),
];
