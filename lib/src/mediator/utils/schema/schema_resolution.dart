import 'package:equatable/equatable.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/reader/model/model.dart';

extension OpenApiSchemaResolutionExt on OpenApi {
  SchemaResolutionInfo resolveSchema(final Reference<Schema> reference) {
    if (reference.ref.startsWith('#/components/schemas/')) {
      final name = reference.ref.removeFromStart('#/components/schemas/');
      final schema = components?.schemas?[name];
      if (schema == null) {
        throw AssertionError('bad reference "${reference.ref}"');
      } else {
        return SchemaResolutionInfo(
          name: name,
          schema: components!.schemas![name]!,
        );
      }
    } else {
      throw UnimplementedError(
        'unsupported schema reference "${reference.ref}"',
      );
    }
  }
}

class SchemaResolutionInfo extends Equatable {
  final String name;
  final ReferenceOr<Schema> schema;

  const SchemaResolutionInfo({
    required this.name,
    required this.schema,
  });

  @override
  List<Object?> get props => [
        name,
        schema,
      ];

  @override
  String toString() => 'SchemaResolutionInfo{name: $name, '
      'schema: $schema}';
}
