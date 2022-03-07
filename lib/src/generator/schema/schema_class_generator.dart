import 'package:equatable/equatable.dart';
import 'package:fantom/src/generator/components/components.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/schema/schema_default_value_generator.dart';
import 'package:fantom/src/generator/schema/schema_enum_generator.dart';
import 'package:fantom/src/generator/schema/schema_from_json_generator.dart';
import 'package:fantom/src/generator/schema/schema_to_json_generator.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:recase/recase.dart';

extension SchemaClassGeneratorExt on SchemaClassGenerator {
  /// this method generates the given dataElement and returns it. but also checks if
  /// there is any enums in the properties of this dataElement. if there is it will register them
  /// in [GeneratedComponentsRegistery] as [GeneratedEnumComponent]
  GeneratedSchemaComponent generateWithEnums(DataElement dataElement) {
    // if (dataElement.isEnumerated || dataElement.isArrayDataElement) {
    // }
    late GeneratedSchemaComponent nodeComponent;
    if (dataElement.isGeneratable) {
      nodeComponent = generate(dataElement.asObjectDataElement);
    } else {
      nodeComponent = UnGeneratableSchemaComponent(dataElement: dataElement);
    }
    final subEnums =
        SchemaEnumGenerator().generateRecursively(dataElement).subs;

    // ignore: avoid_function_literals_in_foreach_calls
    for (var subEnumComponent in subEnums) {
      registerGeneratedEnumComponent(subEnumComponent);
    }
    return nodeComponent;
  }

  GeneratedSchemaComponent generate(
    final ObjectDataElement object,
  ) {
    return GeneratedSchemaComponent(
      dataElement: object,
      fileContent: generateCode(object),
      fileName: '${ReCase(object.name).snakeCase}.dart',
    );
  }

  GeneratedClassesRecursively generateRecursively(final DataElement element) {
    return GeneratedClassesRecursively(
      node: (element is ObjectDataElement &&
              element.format != ObjectDataElementFormat.map)
          ? generate(element)
          : null,
      sub: _generateRecursively(
        element,
        generateSelf: false,
      ),
    );
  }

  List<GeneratedSchemaComponent> _generateRecursively(
    final DataElement element, {
    final bool generateSelf = true,
  }) {
    return [
      if (generateSelf &&
          element is ObjectDataElement &&
          element.format != ObjectDataElementFormat.map)
        generate(element),
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

class SchemaClassGenerator {
  const SchemaClassGenerator();

  String generateCode(
    final ObjectDataElement object, {
    final String? additionalCode,
    final bool generateJson = true,
    final bool inlineJson = false,
    final bool generateEquatable = true,
    final bool generateToString = true,
    final bool generateCopyWith = true,
  }) {
    final name = object.name;
    final format = object.format;

    if (format == ObjectDataElementFormat.map) {
      throw AssertionError(
        'map objects should not be generated : name is $name',
      );
    }

    if (format == ObjectDataElementFormat.mixed) {
      throw UnimplementedError(
        'mixed objects are not supported : name is $name',
      );
    }

    return [
      [
        'class $name ',
        if (generateEquatable) 'extends Equatable ',
        '{',
      ].joinParts(),
      _fields(object),
      _constructor(object),
      _copyWithMethod(name, object),
      if (generateJson)
        [
          SchemaToJsonGenerator().generateForClass(
            object,
            inline: inlineJson,
          ),
          SchemaFromJsonGenerator().generateForClass(
            object,
            inline: inlineJson,
          ),
        ].joinMethods(),
      if (generateEquatable) _equatable(object),
      if (generateToString) _toString(object),
      if (additionalCode != null) additionalCode,
      '}',
    ].joinMethods();
  }

  String _fields(final ObjectDataElement object) {
    return [
      for (final property in object.properties)
        [
          'final ',
          property.item.type,
          ' ',
          property.name,
          ';',
        ].joinParts(),
    ].joinLines();
  }

  String _copyWithMethod(
    final String className,
    final ObjectDataElement object,
  ) {
    if (object.properties.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();

    buffer.writeln('$className copyWith({'); // copyWith method open
    for (var property in object.properties) {
      if (property.item.isNullable) {
        buffer.writeln('Optional<${property.item.type}>? ${property.name},');
      } else {
        var type = property.item.type;
        if (!type.endsWith('?')) {
          type += '?';
        }
        buffer.writeln('   $type ${property.name},');
      }
    }
    buffer.writeln('}) {'); // copyWith method open
    buffer.writeln('   return $className(');
    for (var property in object.properties) {
      if (property.item.isNullable) {
        buffer.writeln(
            '   ${property.name}: (${property.name} != null) ? ${property.name}.value : this.${property.name},');
      } else {
        buffer.writeln(
            '   ${property.name}: ${property.name} ?? this.${property.name},');
      }
    }
    buffer.writeln('  );');
    buffer.writeln('}'); // copyWith method close

    return buffer.toString();
  }

  String _constructor(final ObjectDataElement object) {
    final name = object.name;
    if (object.properties.isEmpty) {
      return '$name ();';
    } else {
      final sdvg = SchemaDefaultValueGenerator();
      return [
        'const $name ({',
        [
          for (final property in object.properties)
            [
              if (property.item.isNotNullable &&
                  property.item.hasNotDefaultValue)
                'required ',
              'this.',
              property.name,
              if (property.item.hasDefaultValue &&
                  property.item.defaultValue!.value != null)
                [
                  ' = ',
                  sdvg.generate(property.item),
                ].joinParts(),
              ',',
            ].joinParts(),
        ].joinLines(),
        '});',
      ].joinLines();
    }
  }

  String _equatable(final ObjectDataElement object) {
    return [
      '@override',
      'List<Object?> get props => [',
      for (final property in object.properties)
        [
          property.name,
          ',',
        ].joinParts(),
      '];',
    ].joinLines();
  }

  String _toString(final ObjectDataElement object) {
    final name = object.name;
    return [
      '@override',
      'String toString() => ',
      "'$name('",
      for (final property in object.properties)
        [
          "'",
          property.name,
          ': ',
          '\$',
          property.name,
          ",'",
        ].joinParts(),
      "')';",
    ].joinLines();
  }
}

class GeneratedClassesRecursively extends Equatable {
  final GeneratedSchemaComponent? node;
  final List<GeneratedSchemaComponent> sub;

  const GeneratedClassesRecursively({
    required this.node,
    required this.sub,
  });

  @override
  List<Object?> get props => [
        node,
        sub,
      ];

  @override
  String toString() => 'GeneratedClassesRecursively{node: $node, '
      'sub: $sub}';

  List<GeneratedSchemaComponent> get all => [
        if (node != null) node!,
        ...sub,
      ];
}
