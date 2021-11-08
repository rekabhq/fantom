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
  }) {
    final content = generateClass(
      object,
      additionalCode: additionalCode,
      inlineJson: inlineJson,
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
  }) {
    final name = object.name;
    final format = object.format;

    if (format == ObjectDataElementFormat.map) {
      // todo: remove quick fix :D
      if (name.contains('_DNG')) {
        return 'class $name {}';
      }

      throw AssertionError(
        'map objects should not be generated : name is $name',
      );
    }

    if (format == ObjectDataElementFormat.mixed) {
      throw UnimplementedError(
        'mixed objects are not supported : name is $name',
      );
    }

    for (final property in object.properties) {
      if (property.item.type == null) {
        throw UnimplementedError('anonymous inner objects are not supported');
      }
    }

    return [
      'class $name {',
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
          property.item.type!,
          if (property.isFieldOptional) '>?',
          ' ',
          property.name,
          ';',
        ].joinParts(),
    ].joinLines();
  }

  String _constructor(final ObjectDataElement object) {
    if (object.properties.isEmpty) {
      return '${object.name} ();';
    } else {
      final sdvg = SchemaDefaultValueGenerator();
      return [
        '${object.name} ({',
        [
          for (final property in object.properties)
            [
              if (property.isRequired && property.item.isNotNullable)
                'required ',
              if (property.isConstructorOptional) 'Optional<',
              property.item.type!,
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
                  sdvg.generate(property.item)!,
                ].joinParts(),
              ',',
            ].joinParts(),
        ].joinLines().replaceFromLast(',', ';'),
      ].joinLines();
    }
  }
}
