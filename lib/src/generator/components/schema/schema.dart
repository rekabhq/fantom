import 'package:fantom/src/openapi/model/model.dart';

class SchemaGenerator {
  const SchemaGenerator();

  List<String> generate(final Map<String, Schema> schemas) =>
      schemas.entries.mapToList(
        (entry) => _generate(entry.key, entry.value),
      );

  String _generate(final String className, final Schema schema) {
    switch (schema.type) {
      case 'null':
        throw UnimplementedError();
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
        if (schema.format != null) throw AssertionError();
        if (schema.defaultValue != null) throw UnimplementedError();
        if (schema.deprecated != null) throw UnimplementedError();
        if (schema.items != null) throw AssertionError();
        if (schema.uniqueItems != null) throw AssertionError();
        throw UnimplementedError();
      default:
        throw UnimplementedError();
    }
  }
}

extension on String {
  String removeFromStart(final String start) {
    if (!startsWith(start)) {
      throw AssertionError();
    }
    return substring(start.length);
  }
}

extension on Reference<Schema> {
  /// get class name for a schema reference
  String get className => ref.removeFromStart('#components/schemas/');
}
