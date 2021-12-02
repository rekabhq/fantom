import 'package:equatable/equatable.dart';
import 'package:fantom/src/generator/components/components.dart';
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

    final List<Object> values = element.enumeration!.values;
    final length = values.length;
    final enumName = element.enumName;
    final typeNN = element.rawTypeNN;
    final svg = SchemaValueGenerator();
    final serNames = [
      for (var index = 0; index < length; index++)
        SchemaEnumGenerator._itemName(element, index),
    ];
    final enumNames = [
      for (var index = 0; index < length; index++)
        SchemaEnumGenerator.valueName(element, index),
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
          '$typeNN serialize() => ',
          'fantomEnumSerialize',
          // if you found issues with type inference, the comment out:
          // '<$enumName, $typeNN>',
          '(',
          'values: $enumName.values, ',
          'items: ${enumName}Ext.items, ',
          'value: this,',
          ');'
        ].joinLines(),
        // deserialize:
        [
          'static $enumName deserialize($typeNN item) => ',
          'fantomEnumDeserialize',
          // if you found issues with type inference, the comment out:
          // '<$enumName, $typeNN>',
          '(',
          'values: $enumName.values, ',
          'items: ${enumName}Ext.items, ',
          'item: item,',
          ');'
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

  static String _nameForIndex(
    final DataElement element,
    final int index,
    final String prefix,
  ) {
    if (element.isEnumerated) {
      if (element is StringDataElement &&
          element.format == StringDataElementFormat.plain) {
        final value = element.enumeration!.values[index];
        if (value is! String) {
          throw AssertionError('bad types');
        }

        // todo: is this really needed ?
        if (prefix == 'item') {
          final f = value.substring(0, 1);
          final fu = f.toUpperCase();
          if (f == fu) {
            return 'ITEM_$value';
          } else {
            return 'item' + (fu + value.substring(1, value.length));
          }
        }

        return value;
      } else {
        return '$prefix$index';
      }
    } else {
      throw AssertionError('element is not enumerated');
    }
  }

  /// ex. success
  /// ex. item3
  static String _itemName(final DataElement element, final int index) {
    return _nameForIndex(element, index, 'item');
  }

  /// ex. success
  /// ex. value3
  static String valueName(final DataElement element, final int index) {
    return _nameForIndex(element, index, 'value');
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
