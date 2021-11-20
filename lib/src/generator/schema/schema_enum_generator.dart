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
    final length = values.length;
    final enumName = element.enumName;
    final type = element.rawType;
    final svg = SchemaValueGenerator();
    final serNames = [
      for (var index = 0; index < length; index++) 'item$index',
    ];
    final enumNames = [
      for (var index = 0; index < length; index++) enumItemName(element, index),
    ];
    return [
      // enum:
      [
        'enum $enumName {',
        for (var index = 0; index < length; index++)
          [
            enumNames[index],
            ',',
          ].joinParts(),
        '}',
      ].joinLines(),
      // enum serialization and values class:
      [
        'extension ${enumName}Ext on $enumName {',
        // serialize:
        [
          '$type serialize() {',
          'for (var index = 0; index < items.length; index++) {',
          'if($enumName.values[index] == this) {',
          'return items[index];',
          '}',
          '}',
          "throw AssertionError('not found');",
          '}',
        ].joinLines(),
        // deserialize:
        [
          'static $enumName deserialize(final $type item) {',
          'for (var index = 0; index < items.length; index++) {',
          'if(_equals(items[index], item)) {',
          'return $enumName.values[index];',
          '}',
          '}',
          "throw AssertionError('not found');",
          '}',
        ].joinLines(),
        // item#index:
        [
          for (var index = 0; index < length; index++)
            [
              'static final $type ',
              serNames[index],
              ' = ',
              svg.generate(
                element,
                value: values[index],
                ignoreTopEnum: true,
              ),
              ';',
            ].joinParts(),
        ].joinLines(),
        // items:
        [
          'static final List<$type> items = [',
          for (var index = 0; index < length; index++)
            [
              serNames[index],
              ',',
            ].joinParts(),
          '];',
        ].joinLines(),
        '}',
      ].joinMethods(),
    ].joinMethods();
  }

  static String enumItemName(final DataElement element, final int index) {
    if (element.isEnumerated) {
      if (element is StringDataElement &&
          element.isNotNullable &&
          element.format == StringDataElementFormat.plain) {
        final value = element.enumeration!.values[index];
        if (value is! String) {
          throw AssertionError('bad types');
        }
        return value;
      } else {
        return 'value$index';
      }
    } else {
      throw AssertionError('not enumerated');
    }
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
