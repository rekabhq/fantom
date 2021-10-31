import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/schema/schema_default_value_generator.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:recase/recase.dart';

// todo: should be copied.
class Optional<T> {
  final T value;

  const Optional(this.value);
}

class SchemaClassGenerator {
  const SchemaClassGenerator();

  // todo: default value is not supported
  GeneratedSchemaComponent generate(
    final ObjectDataElement object, {
    @Deprecated('do not use') String? orName,
  }) {
    final name = object.name ?? orName;
    final format = object.format;

    if (name == null) {
      throw UnimplementedError('anonymous objects are not supported');
    }
    if (format != ObjectDataElementFormat.object) {
      throw UnimplementedError(
        '"mixed" and "map" objects are not supported : name is $name',
      );
    }
    for (final property in object.properties) {
      if (property.item.type == null) {
        throw UnimplementedError('anonymous inner objects are not supported');
      }
    }

    final dvg = SchemaDefaultValueGenerator();
    final output = object.properties.isEmpty
        // empty class:
        ? 'class $name {}'
        // non-empty class:
        : [
            'class $name {',
            // ...
            [
              for (final property in object.properties)
                [
                  'final ',
                  if (property.isNotRequired &&
                      property.item.hasNotDefaultValue)
                    'Optional<',
                  property.item.type!,
                  if (property.isNotRequired &&
                      property.item.hasNotDefaultValue)
                    '>?',
                  ' ',
                  property.name,
                  ';',
                ].joinParts(),
            ].joinLines(),
            // ...
            [
              '${object.name} ({',
              // .../...
              [
                for (final property in object.properties)
                  [
                    if (property.isRequired && property.item.isNotNullable)
                      'required ',
                    if (property.isNotRequired) 'Optional<',
                    property.item.type!,
                    if (property.isNotRequired) '>?',
                    ' ',
                    property.name,
                    ',',
                  ].joinParts(),
              ].joinLines(),
              '}) : ',
              // .../...
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
                        dvg.generate(property.item)!,
                      ].joinParts(),
                    ',',
                  ].joinParts(),
              ].joinLines().replaceFromLastOrNot(',', ';'),
            ].joinLines(),
            '}',
          ].joinLines();

    return GeneratedSchemaComponent(
      dataElement: object,
      fileContent: output,
      fileName: '${ReCase(name).snakeCase}.dart',
    );
  }
}
