import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:fantom/src/writer/generatbale_file.dart';

Future<List<GeneratableFile>> getUtilityFiles() async {
  return [
    await _createGeneratableFile(
      relativePath: 'src/generator/schema/copy.dart',
      fileName: 'equatbles.dart',
    ),
    await _createGeneratableFile(
      relativePath: 'src/generator/api/method/uri_parser.dart',
      fileName: 'uri_parser.dart',
    ),
    await _createGeneratableFile(
      relativePath: 'src/generator/api/method/result.dart',
      fileName: 'result.dart',
    ),
  ];
}

Future<GeneratableFile> _createGeneratableFile({
  required String fileName,
  required String relativePath,
}) async {
  final file = await getSourceFileAsAsset(relativePath);
  return GeneratableFile.fromFile(
    file,
    fileName: fileName,
  );
}
