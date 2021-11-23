import 'package:fantom/src/generator/schema_optional/schema_value_generator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';

class SchemaDefaultValueGenerator {
  const SchemaDefaultValueGenerator();

  /// no checking for types. assuming all is correct.
  ///
  /// return null if no default value
  String? generateOrNull(final DataElement element) {
    final defaultValue = element.defaultValue;
    if (defaultValue == null) {
      return null;
    } else {
      final svg = SchemaValueGenerator();
      return svg.generate(
        element,
        value: defaultValue.value,
      );
    }
  }
}
