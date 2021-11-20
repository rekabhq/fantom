import 'package:equatable/equatable.dart';
import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/schema/schema_value_generator.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:recase/recase.dart';

extension SchemaEnumGeneratorExt on SchemaEnumGenerator {
  GeneratedSchemaComponent generate(
    final DataElement element,
  ) {
    return GeneratedSchemaComponent(
      dataElement: element,
      fileContent: generateEnum(element),
      fileName: '${ReCase(element.enumName).snakeCase}.dart',
    );
  }

  List<GeneratedSchemaComponent> generateRecursively(
    final DataElement element,
  ) {
    return generateEnumsRecursively(element)
        .map((e) => GeneratedSchemaComponent(
            dataElement: e.element,
            fileContent: e.code,
            fileName: '${ReCase(e.element.enumName).snakeCase}.dart'))
        .toList();
  }
}

class SchemaEnumGenerator {
  const SchemaEnumGenerator();

  List<GeneratedEnum> generateEnumsRecursively(final DataElement element) {
    return [
      if (element.isEnumerated) _generate(element),
      ...element.match(
        boolean: (boolean) => [],
        object: (object) => [
          for (final property in object.properties)
            ...generateEnumsRecursively(property.item),
          if (object.isAdditionalPropertiesAllowed)
            ...generateEnumsRecursively(object.additionalProperties!),
        ],
        array: (array) => [
          ...generateEnumsRecursively(array.items),
        ],
        integer: (integer) => [],
        number: (number) => [],
        string: (string) => [],
        untyped: (untyped) => [],
      )
    ];
  }

  String generateEnum(final DataElement element) {
    if (element.isNotEnumerated) {
      throw AssertionError(
        'element ${element.name} does not contain an enum',
      );
    }
    return _generateCode(element);
  }

  GeneratedEnum _generate(final DataElement element) {
    return GeneratedEnum(
      element: element,
      code: _generateCode(element),
    );
  }

  String _generateCode(final DataElement element) {
    final List<Object?> values = element.enumeration!.values;
    final name = element.enumName;
    final type = element.rawType;
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
        'extension ${name}Ext on $name {',
        // serialize:
        [
          '$type serialize() {',
          'switch(this) {',
          for (var index = 0; index < values.length; index++)
            [
              'case $name.',
              names[index],
              ': return ',
              names[index],
              ';',
            ].joinParts(),
          '}',
          "throw AssertionError('not found');",
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

class GeneratedEnum extends Equatable {
  final DataElement element;
  final String code;

  GeneratedEnum({
    required this.element,
    required this.code,
  });

  @override
  List<Object?> get props => [
        element,
        code,
      ];

  @override
  String toString() => 'GeneratedEnum{element: $element, '
      'code: $code}';
}
