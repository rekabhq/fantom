import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:fantom/src/writer/generatbale_file.dart';

/// returns utility files that are going to be copied with the generated api/model classes since the content
/// of these utility files are used in generated classes
///
Future<List<GeneratedFile>> getUtilityFiles() async {
  return [
    await createGeneratableFileFromSourceFile(
      relativePath: 'src/generator/schema/equatables.dart',
      fileName: 'equatbles.dart',
    ),
    await createGeneratableFileFromSourceFile(
      relativePath: 'src/generator/schema/optional.dart',
      fileName: 'optional.dart',
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
