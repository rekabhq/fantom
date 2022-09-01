import 'package:fantom/src/generator/components/components.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/parameter/parameter_from_content_generator.dart';
import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/mediator/mediator/schema/schema_mediator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/utils/utililty_functions.dart';
import 'package:recase/recase.dart';

class ParameterClassGenerator {
  const ParameterClassGenerator({
    required this.schemaGenerator,
    required this.schemaMediator,
    required this.openApi,
  });

  final SchemaClassGenerator schemaGenerator;
  final SchemaMediator schemaMediator;
  final OpenApi openApi;

  GeneratedParameterComponent generate(
    final OpenApi openApi,
    final Parameter parameter,
    final String nameSeed,
  ) {
    // user+id+query+parameter = UserIdQueryParameter
    final typeName =
        '$nameSeed/${parameter.name}/${parameter.location}/parameter'
            .pascalCase;

    if (parameter.schema != null && parameter.content != null) {
      throw StateError('Parameter can not have both schema and content');

      /// parameter value has a content. so we should return a content manifest
      /// and sealed class
    } else if (parameter.content != null) {
      List<GeneratedSchemaComponent> generatedComponents = [];
      // we need to replace */* with any in our content-types since it cannot be used in code generation
      final removed = parameter.content!.remove('*/*');
      if (removed != null) {
        parameter.content!['any'] = removed;
      }

      Map<String, GeneratedSchemaComponent> map = {};

      for (var entry in parameter.content!.entries) {
        GeneratedSchemaComponent? component;
        final mediaType = entry.value;
        final contentType = entry.key;
        final refOrSchema = mediaType.schema;
        if (refOrSchema != null) {
          if (refOrSchema.isReference) {
            component = getGeneratedComponentByRef(refOrSchema.reference.ref)
                as GeneratedSchemaComponent;
          } else {
            // our schema object first needs to be generated
            component = createSchemaClassFrom(
              schema: refOrSchema,
              name:
                  '$typeName${ReCase(getContentTypeShortName(contentType)).pascalCase}'
                      .pascalCase,
              schemaClassGenerator: schemaGenerator,
              schemaMediator: schemaMediator,
              openApi: openApi,
            );
            generatedComponents.add(component);
          }
        }
        if (component != null) {
          map[contentType] = component;
        }
      }

      /// create and generate sealed class base on parameter content values
      final sealedClassContent = createParameterClassFromContent(
        typeName: typeName,
        contentMap: map,
      );
      final buffer = StringBuffer();

      buffer.writeln(sealedClassContent);

      /// add relative classes in end of the file
      for (final component in generatedComponents) {
        buffer.writeln(component.fileContent);
      }
      final fileContent = buffer.toString();
      final fileName = '${typeName.snakeCase}.dart';

      return GeneratedParameterComponent.content(
        fileName: fileName,
        fileContent: fileContent,
        source: parameter,
        contentTypeName: typeName,
      );
      // parameter value has a schema. so we should return a schema generated component
    } else {
      final className = typeName.pascalCase;

      final schema = parameter.schema!;

      /// if schema is reference, we will find it from component collection
      /// otherwise we will generate it with schema mediator
      final DataElement element = _findSchemaElement(
        openApi,
        schema,
        name: className,
      );
      final generatedSchema = schemaGenerator.generateWithEnums(element);
      if (generatedSchema.isGenerated) {
        return GeneratedParameterComponent.schema(
          source: parameter,
          schemaComponent: generatedSchema,
          fileContent: generatedSchema.fileContent,
          fileName: generatedSchema.fileName,
        );
      } else {
        return UnGeneratableParameterComponent(
          source: parameter,
          schemaComponent: UnGeneratableSchemaComponent(dataElement: element),
        );
      }
    }
  }

  DataElement _findSchemaElement(
    OpenApi openApi,
    ReferenceOr<Schema> schema, {
    required String name,
  }) {
    if (schema.isReference) {
      final generatedComponent = getGeneratedComponentByRef(
        schema.reference.ref,
      );

      if (generatedComponent is GeneratedSchemaComponent) {
        return generatedComponent.dataElement;
      } else if (generatedComponent == null) {
        return schemaMediator.convert(
          openApi: openApi,
          schema: schema,
          name: name,
          schemaRef: schema.isReference ? schema.reference.ref : '',
        );
      } else {
        throw StateError('Unexpected generated component type');
      }
    }

    return schemaMediator.convert(
      openApi: openApi,
      schema: schema,
      name: name,
      schemaRef: schema.isReference ? schema.reference.ref : '',
    );
  }
}
