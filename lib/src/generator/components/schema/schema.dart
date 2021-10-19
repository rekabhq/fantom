import 'package:fantom/src/openapi/model/model.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';

/// supports `3.1` and partially `>=3.0 <3.1`.
class SchemaGenerator {
  /// weather we should be compatible with `3.0` or not.
  final bool compatibilityMode;

  const SchemaGenerator({
    this.compatibilityMode = false,
  });

  List<String> generate(final Map<String, Schema> schemas) {
    throw UnimplementedError();
  }
}

extension SchemaReferenceExt on Reference<Schema> {
  /// get class name for a schema reference
  String get className => ref.removeFromStart('#components/schemas/');
}
