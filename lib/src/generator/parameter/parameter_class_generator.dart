import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';

class ParameterClassGenerator {
  const ParameterClassGenerator();

  // todo: default value is not supported
  GeneratedParameterComponent generate(
    SchemaClassGenerator schemaGenerator,
    final DataElement element,
  ) {
    if (element is ObjectDataElement) {
      final generatedSchema = schemaGenerator.generate(element);
      return GeneratedParameterComponent(
        dataElement: element,
        schemaComponent: generatedSchema,
        fileContent: generatedSchema.fileContent,
        fileName: generatedSchema.fileName,
      );
    } else {
      return GeneratedParameterComponent(
        dataElement: element,
        schemaComponent: UnGeneratableSchemaComponent(dataElement: element),
        fileContent: '',
        fileName: '',
      );
    }
  }
}
