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
          for (final property in object.properties)
            ..._generateRecursively(property.item),
          if (object.isAdditionalPropertiesAllowed)
            ..._generateRecursively(object.additionalProperties!),
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

    final List<Object?> values = element.enumeration!.values;
    final length = values.length;
    final enumName = element.enumName;
    final type = element.rawType;
    final svg = SchemaValueGenerator();
    final serNames = [
      for (var index = 0; index < length; index++) 'item$index',
    ];
    final enumNames = [
      for (var index = 0; index < length; index++)
        SchemaEnumGenerator.enumItemName(element, index),
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
