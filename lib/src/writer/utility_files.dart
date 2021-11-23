import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:fantom/src/writer/generatbale_file.dart';

Future<List<GeneratableFile>> getUtilityFiles() async {
  return [
    await createGeneratableFileFromSourceFile(
      relativePath: 'src/generator/schema/copy.dart',
      fileName: 'equatbles.dart',
    ),
    await createGeneratableFileFromSourceFile(
      relativePath: 'src/generator/api/method/uri_parser.dart',
      fileName: 'uri_parser.dart',
    ),
    await createGeneratableFileFromSourceFile(
      relativePath: 'src/generator/api/method/result.dart',
      fileName: 'result.dart',
    ),
  ];
}
