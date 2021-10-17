import 'package:fantom/src/openapi/model/model.dart';

class SchemaGenerator {
  const SchemaGenerator();

  List<String> generate(final Map<String, Schema> schemas) =>
      schemas.entries.mapToList(
        (entry) => _generate(entry.key, entry.value),
      );

  String _generate(final String className, final Schema schema) {
    switch (schema.type) {
      case 'string':
        throw UnimplementedError();
      case 'number':
        throw UnimplementedError();
      case 'integer':
        throw UnimplementedError();
      case 'boolean':
        throw UnimplementedError();
      case 'array':
        throw UnimplementedError();
      case 'object':
        throw UnimplementedError();
      default:
        throw UnimplementedError();
    }
  }

  String _className(final Reference<Schema> reference) =>
      reference.ref.removeFromStart('#components/schemas/');
}

extension on String {
  String removeFromStart(final String start) {
    if (!startsWith(start)) {
      throw AssertionError();
    }
    return substring(start.length);
  }
}
