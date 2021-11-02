import 'package:fantom/src/writer/file_writer.dart';

const allNeccessaryFiles = [
  GeneratableFile(
    fileName: 'optional.dart',
    fileContent: r'''
class Optional<T> {
  final T value;

  const Optional(this.value);
}    
    ''',
  ),
];
