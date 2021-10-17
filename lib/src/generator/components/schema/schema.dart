import 'package:fantom/src/openapi/model/model.dart';

abstract class SchemaGenerator {
  const SchemaGenerator();

  List<SchemaElement> generate(
    Map<String, Schema>? schemas,
    Referenceable<Schema> schema,
  ) {
    schemas ??= const {};
    throw 0;
  }
}

class SchemaElement {
  final String className;

  final String code;

  const SchemaElement({
    required this.className,
    required this.code,
  });
}
