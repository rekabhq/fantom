import 'package:equatable/equatable.dart';
import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/schema/schema_value_generator.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:recase/recase.dart';

extension SchemaEnumGeneratorExt on SchemaEnumGenerator {
  GeneratedEnumComponent generate(final DataElement element) {
    return GeneratedEnumComponent(
      dataElement: element,
      fileContent: generateCode(element),
      fileName: '${ReCase(element.enumName).snakeCase}.dart',
    );
  }

  GeneratedEnumsRecursively generateRecursively(
    final DataElement element,
  ) {
    return GeneratedEnumsRecursively(
      node: element.isEnumerated ? generate(element) : null,
      subs: _generateRecursively(
        element,
        generateSelf: false,
      ),
    );
  }

  List<GeneratedEnumComponent> _generateRecursively(
    final DataElement element, {
    final bool generateSelf = true,
  }) {
    return [
      if (generateSelf && element.isEnumerated) generate(element),
      ...element.match(
        boolean: (boolean) => [],
        object: (object) => [
          for (final property in object.properties) ..._generateRecursively(property.item),
          if (object.isAdditionalPropertiesAllowed) ..._generateRecursively(object.additionalProperties!),
        ],
        array: (array) => [
          ..._generateRecursively(array.items),
        ],
        integer: (integer) => [],
        number: (number) => [],
        string: (string) => [],
        untyped: (untyped) => [],
      ),
    ];
  }
}

class SchemaEnumGenerator {
  const SchemaEnumGenerator();

  String generateCode(final DataElement element) {
    if (element.isNotEnumerated) {
      throw AssertionError(
        'element ${element.name} does not contain an enum',
      );
    }

    final List<Object> values = element.enumeration!.values;
    final length = values.length;
    final enumName = element.enumName;
    final typeNN = element.rawTypeNN;
    final svg = SchemaValueGenerator();
    final serNames = [
      for (var index = 0; index < length; index++) 'item$index',
    ];
    final enumNames = [
      for (var index = 0; index < length; index++) SchemaEnumGenerator.enumItemName(element, index),
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
        // empty enums are not supported in dart, so:
        if (values.isEmpty) r'$EMPTY$,',
        '}',
      ].joinLines(),
      // enum serialization and values class:
      [
        'extension ${enumName}Ext on $enumName {',
        // serialize:
        [
          '$typeNN serialize() {',
          'for (var index = 0; index < ${enumName}Ext.items.length; index++) {',
          'if($enumName.values[index] == this) {',
          'return ${enumName}Ext.items[index];',
          '}',
          '}',
          "throw AssertionError('not found');",
          '}',
        ].joinLines(),
        // deserialize:
        [
          'static $enumName deserialize(final $typeNN item) {',
          'for (var index = 0; index < ${enumName}Ext.items.length; index++) {',
          'if(fantomEquals(${enumName}Ext.items[index], item)) {',
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
              'static const $typeNN ',
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
          'static const List<$typeNN> items = [',
          for (var index = 0; index < length; index++)
            [
              '${enumName}Ext.',
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
      if (element is StringDataElement && element.format == StringDataElementFormat.plain) {
        final value = element.enumeration!.values[index];
        if (value is! String) {
          throw AssertionError('bad types');
        }
        return value;
      } else {
        return 'value$index';
      }
    } else {
      throw AssertionError('element is not enumerated');
    }
  }
}

class GeneratedEnumsRecursively extends Equatable {
  final GeneratedEnumComponent? node;
  final List<GeneratedEnumComponent> subs;

  const GeneratedEnumsRecursively({
    required this.node,
    required this.subs,
  });

  @override
  List<Object?> get props => [
        node,
        subs,
      ];

  @override
  String toString() => 'GeneratedEnumsRecursively{node: $node, '
      'sub: $subs}';

  List<GeneratedEnumComponent> get all => [
        if (node != null) node!,
        ...subs,
      ];
}
