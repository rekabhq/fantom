import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/schema/schema_default_value_generator.dart';
import 'package:fantom/src/generator/schema/schema_from_json_generator.dart';
import 'package:fantom/src/generator/schema/schema_to_json_generator.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:recase/recase.dart';

extension SchemaClassGeneratorExt on SchemaClassGenerator {
  GeneratedSchemaComponent generate(
    final ObjectDataElement object, {
    final String? additionalCode,
    final bool generateJson = true,
    final bool inlineJson = false,
    final bool generateEquatable = true,
    final bool generateToString = true,
  }) {
    final content = generateClass(
      object,
      additionalCode: additionalCode,
      inlineJson: inlineJson,
      generateEquatable: generateEquatable,
      generateToString: generateToString,
    );
    return GeneratedSchemaComponent(
      dataElement: object,
      fileContent: content,
      fileName: '${ReCase(object.name).snakeCase}.dart',
    );
  }
}

class SchemaClassGenerator {
  const SchemaClassGenerator();

  String generateClass(
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
      // todo: remove quick fix
      return 'class $name {}';
      // throw AssertionError(
      //   'map objects should not be generated : name is $name',
      // );
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
