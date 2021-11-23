import 'package:equatable/equatable.dart';
import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/schema_optional/schema_default_value_generator.dart';
import 'package:fantom/src/generator/schema_optional/schema_from_json_generator.dart';
import 'package:fantom/src/generator/schema_optional/schema_to_json_generator.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema_optional/schema_model.dart';

class SchemaClassGenerator {
  const SchemaClassGenerator();

  String generateCode(
    final ObjectDataElement object, {
    final String? additionalCode,
    final bool generateJson = true,
    final bool inlineJson = false,
    final bool generateEquatable = true,
    final bool generateToString = true,
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
          if (property.isFieldOptional) 'Optional<',
          property.item.type,
          if (property.isFieldOptional) '>?',
          ' ',
          property.name,
          ';',
        ].joinParts(),
    ].joinLines();
  }

  String _constructor(final ObjectDataElement object) {
    final name = object.name;
    if (object.properties.isEmpty) {
      return '$name ();';
    } else {
      final sdvg = SchemaDefaultValueGenerator();
      return [
        '$name ({',
        [
          for (final property in object.properties)
            [
              if (property.isConstructorRequired) 'required ',
              if (property.isConstructorOptional) 'Optional<',
              property.item.type,
              if (property.isConstructorOptional) '>?',
              ' ',
              property.name,
              ',',
            ].joinParts(),
        ].joinLines(),
        '}) : ',
        [
          for (final property in object.properties)
            [
              property.name,
              ' = ',
              property.name,
              if (property.item.hasDefaultValue)
                [
                  ' != null ? ',
                  property.name,
                  '.value : ',
                  sdvg.generateOrNull(property.item)!,
                ].joinParts(),
              ',',
            ].joinParts(),
        ].joinLines().replaceFromLast(',', ';'),
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
