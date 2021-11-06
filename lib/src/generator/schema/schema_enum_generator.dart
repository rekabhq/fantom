import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:recase/recase.dart';

class SchemaEnumGenerator {
  const SchemaEnumGenerator();

  GeneratedSchemaComponent generate(
    final DataElement element, {
    required final String name,
  }) {
    return GeneratedSchemaComponent(
      dataElement: element,
      fileContent: _generate(element, name),
      fileName: _fileName(name),
    );
  }

  String _generate(final DataElement element, final String name) {
    final enumeration = element.enumeration;
    if (enumeration == null) {
      throw AssertionError('element ${element.name} does not contain an enum');
    }

    return [''].joinParts();
  }

  String _fileName(final String name) {
    return '${ReCase(name).snakeCase}.dart';
  }
}
