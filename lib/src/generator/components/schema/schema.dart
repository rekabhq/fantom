import 'package:fantom/src/openapi/model/model.dart';

abstract class SchemaGenerator {
  const SchemaGenerator();

  List<SchemaElement> generate(Schema schema);
}

class SchemaElement {
  final String className;

  final String code;

  const SchemaElement({
    required this.className,
    required this.code,
  });
}
