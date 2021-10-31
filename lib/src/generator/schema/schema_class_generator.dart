import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:recase/recase.dart';

// todo: should be copied.
class Optional$<T> {
  final T value;

  const Optional$(this.value);
}

class SchemaClassGenerator {
  const SchemaClassGenerator();

  // todo: default value is not supported
  GeneratedSchemaComponent generate(
    final ObjectDataElement element, {
    @Deprecated('do not use') String? orName,
  }) {
    final name = element.name ?? orName;
    final format = element.format;

    if (name == null) {
      throw UnimplementedError('anonymous objects are not supported');
    }
    if (format != ObjectDataElementFormat.object) {
      throw UnimplementedError(
        '"mixed" and "map" objects are not supported : name is $name',
      );
    }
    for (final property in element.properties) {
      if (property.item.type == null) {
        throw UnimplementedError('anonymous inner objects are not supported');
      }
      // temporarilly disabled
      // if (property.item.defaultValue != null) {
      //   throw UnimplementedError('default value is not supported');
      // }
    }

    final output = element.properties.isEmpty
        // empty class:
        ? 'class $name {}'
        // non-empty class:
        : [
            'class $name {',
            // ...
            [
              for (final property in element.properties)
                [
                  'final ',
                  if (property.isNotRequired) 'Optional<',
                  property.item.type!,
                  if (property.isNotRequired) '>?',
                  ' ',
                  property.name,
                  ';',
                ].joinParts(),
            ].joinLines(),
            // ...
            [
              '${element.name} ({',
              // .../...
              [
                for (final property in element.properties)
                  [
                    if (property.isRequired) 'required ',
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
                for (final property in element.properties)
                  [
                    property.name,
                    ' = ',
                    property.name,
                    ',',
                  ].joinParts(),
              ].joinLines().replaceFromLastOrNot(',', ';'),
            ].joinLines(),
            '}',
          ].joinLines();

    return GeneratedSchemaComponent(
      dataElement: element,
      fileContent: output,
      fileName: '${ReCase(name).snakeCase}.dart',
    );
  }
}
