import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:recase/recase.dart';

class SchemaClassGenerator {
  const SchemaClassGenerator();

  // todo: default value is not supported
  GeneratedSchemaComponent generate(final ObjectDataElement element) {
    final format = element.format;

    // todo: free form
    if (format != ObjectDataElementFormat.object) {
      throw UnimplementedError(
        '"mixed" and "map" objects are not supported : element name is ${element.name}',
      );
    }
    if (element.name == null) {
      throw UnimplementedError('anonymous objects are not supported');
    }
    for (final property in element.properties!) {
      if (property.item.type == null) {
        throw UnimplementedError('anonymous inner objects are not supported');
      }
    }

    final fileName = '${ReCase(element.name!).snakeCase}.dart';
    final fileContent = [
      'class ${element.name} {',
      // ...
      [
        for (final property in element.properties!)
          [
            'final ',
            if (property.isRequired) 'Optional<',
            property.item.type!,
            if (property.isRequired) '>?',
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
          for (final property in element.properties!)
            [
              'required ',
              if (property.isRequired) 'Optional<',
              property.item.type!,
              if (property.isRequired) '>?',
              ' ',
              property.name,
              ',',
            ].joinParts(),
        ].joinLines(),
        '}) : ',
        // .../...
        [
          for (final property in element.properties!)
            [
              property.name,
              ' = ',
              property.name,
              ',',
            ].joinParts(),
        ].joinLines().removeFromLast(','),
        ';'
      ].joinLines(),
      '}',
    ].joinLines();

    return GeneratedSchemaComponent(
      dataElement: element,
      fileContent: fileContent,
      fileName: fileName,
    );
  }
}
