import 'package:fantom/src/generator/schema/schema_value_generator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';

class SchemaDefaultValueGenerator {
  const SchemaDefaultValueGenerator();

  /// no checking for types. assuming all is correct.
  ///
  /// return null if
  String? generate(final DataElement element) {
    final defaultValue = element.defaultValue;
    if (defaultValue == null) {
      return null;
    } else {
      return SchemaValueGenerator().generate(
        element,
        value: defaultValue.value,
      );
    }
  }
}
