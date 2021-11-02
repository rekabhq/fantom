import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/schema/schema_from_json_generator.dart';
import 'package:fantom/src/generator/schema/schema_to_json_generator.dart';
import 'package:fantom/src/generator/schema/schema_default_value_generator.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:recase/recase.dart';

class SchemaClassGenerator {
  const SchemaClassGenerator();

  GeneratedSchemaComponent generate(final ObjectDataElement object) {
    final name = object.name;
    if (name == null) {
      throw UnimplementedError('anonymous objects are not supported');
    }

    return GeneratedSchemaComponent(
      dataElement: object,
      fileContent: _generate(object),
      fileName: _fileName(object),
    );
  }

  String _fileName(ObjectDataElement object) {
    final name = object.name!;
    return '${ReCase(name).snakeCase}.dart';
  }

  String _generate(final ObjectDataElement object) {
    final name = object.name!;
    final format = object.format;

    if (format != ObjectDataElementFormat.object) {
      // todo: quick fix :D
      if (name.endsWith('_DNG')) {
        return 'class $name {}';
      }

      throw UnimplementedError(
        '"mixed" and "map" objects are not supported : name is $name',
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
      SchemaToJsonGenerator().generateForClass(object),
      SchemaFromJsonGenerator().generateForClass(object),
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
      return [
        '${object.name} ({',
        [
          for (final property in object.properties)
            [
              if (property.isRequired && property.item.isNotNullable)
                'required ',
              if (property.isConstructorOptional)
                'Optional<',
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
                  SchemaDefaultValueGenerator().generate(property.item)!,
                ].joinParts(),
              ',',
            ].joinParts(),
        ].joinLines().replaceFromLast(',', ';'),
      ].joinLines();
    }
  }
}
