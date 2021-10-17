import 'package:fantom/src/openapi/model/model.dart';

class SchemaGenerator {
  const SchemaGenerator();

  List<SchemaElement> generate(final Schema schema) {
    throw UnimplementedError();
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
