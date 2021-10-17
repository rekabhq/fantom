import 'package:fantom/src/openapi/model/model.dart';

class SchemaGenerator {
  const SchemaGenerator();

  List<SchemaElement> generate(final Map<String, Schema> schemas) =>
      schemas.entries.mapToList(
        (entry) => _generate(entry.key, entry.value),
      );

  SchemaElement _generate(final String className, final Schema schema) {
    final code = '';
    return SchemaElement(
      className: className,
      code: code,
    );
  }

  String _className(final Reference<Schema> reference) =>
      reference.ref.removeFromStart('#components/schemas/');
}

class SchemaElement {
  final String className;

  final String code;

  const SchemaElement({
    required this.className,
    required this.code,
  });
}

extension on String {
  String removeFromStart(final String start) {
    if (!startsWith(start)) {
      throw AssertionError();
    }
    return substring(start.length);
  }
}
