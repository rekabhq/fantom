import 'package:fantom/src/generator/schema_optional/schema_value_generator.dart';
import 'package:fantom/src/mediator/model/schema_optional/schema_model.dart';

class SchemaDefaultValueGenerator {
  const SchemaDefaultValueGenerator();

  /// no checking for types. assuming all is correct.
  ///
  /// return null if no default value
  String? generateOrNull(final DataElement element) {
    return element.hasDefaultValue ? _generate(element) : null;
  }

  String generate(final DataElement element) {
    if (element.hasDefaultValue) {
      return _generate(element);
    } else {
      throw AssertionError('no default value for element ${element.name}');
    }
  }

  String _generate(DataElement element) {
    final svg = SchemaValueGenerator();
    return svg.generate(
      element,
      value: element.defaultValue!.value,
    );
  }
}
