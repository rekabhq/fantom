import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/schema/schema_value_generator.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:recase/recase.dart';

extension SchemaEnumGeneratorExt on SchemaEnumGenerator {
  GeneratedSchemaComponent generate(final DataElement element) {
    return GeneratedSchemaComponent(
      dataElement: element,
      fileContent: generateEnum(
        element,
      ),
      fileName: '${ReCase(element.enumName).snakeCase}.dart',
    );
  }
}

class SchemaEnumGenerator {
  const SchemaEnumGenerator();

  String generateEnum(final DataElement element) {
    final enumeration = element.enumeration;
    if (enumeration == null) {
      throw AssertionError(
        'element ${element.name} does not contain an enum',
      );
    }
    return _generate(element, enumeration.values);
  }

  String _generate(
    final DataElement element,
    final List<Object?> values,
  ) {
    final name = element.enumName;
    final type = element.type;
    final svg = SchemaValueGenerator();
    final names = [
      for (var index = 0; index < values.length; index++) 'value$index',
    ];
    return [
      // enum:
      [
        'enum $name {',
        for (var index = 0; index < values.length; index++)
          [
            names[index],
            ',',
          ].joinParts(),
        '}',
      ].joinLines(),
      // enum serialization and values class:
      [
        'abstract class ${name}Serialization {',
        // constructor:
        [
          '${name}Serialization._() {',
          'throw AssertionError();',
          '}',
        ].joinLines(),
        // serialize:
        [
          'static $type serialize(final $name value) {',
          'switch(value) {',
          for (var index = 0; index < values.length; index++)
            [
              'case $name.',
              names[index],
              ': return ',
              names[index],
              ';',
            ].joinParts(),
          '}',
          '}',
        ].joinLines(),
        // deserialize:
        [
          'static $name deserialize(final $type value) {',
          for (var index = 0; index < values.length; index++)
            [
              'if(_equals(value, ',
              names[index],
              ')) return $name.',
              names[index],
              ';',
            ].joinParts(),
          "throw AssertionError('not found');",
          '}',
        ].joinLines(),
        // value#index:
        [
          for (var index = 0; index < values.length; index++)
            [
              'static final $type ',
              names[index],
              ' = ',
              svg.generate(element, value: values[index]),
              ';',
            ].joinParts(),
        ].joinLines(),
        // values:
        [
          'static final List<$type> values = [',
          for (var index = 0; index < values.length; index++)
            [
              names[index],
              ',',
            ].joinParts(),
          '];',
        ].joinLines(),
        '}',
      ].joinMethods(),
    ].joinMethods();
  }
}
