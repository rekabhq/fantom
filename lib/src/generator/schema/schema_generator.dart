import 'package:equatable/equatable.dart';
import 'package:fantom/src/generator/schema/schema_class_generator.dart';
import 'package:fantom/src/generator/schema/schema_enum_generator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';

class SchemaGenerator {
  const SchemaGenerator();

  GeneratedSchema generateRecursively(final DataElement element) {
    return GeneratedSchema(
      classes: SchemaClassGenerator().generateRecursively(element),
      enums: SchemaEnumGenerator().generateRecursively(element),
    );
  }
}

class GeneratedSchema extends Equatable {
  final GeneratedClassesRecursively classes;
  final GeneratedEnumsRecursively enums;

  const GeneratedSchema({
    required this.classes,
    required this.enums,
  });

  @override
  List<Object?> get props => [
        classes,
        enums,
      ];

  @override
  String toString() => 'GeneratedSchema{classes: $classes, enums: $enums}';
}
