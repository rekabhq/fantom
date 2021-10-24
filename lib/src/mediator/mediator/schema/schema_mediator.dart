import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/openapi/model/model.dart';
// import 'package:fantom/src/generator/utils/string_utils.dart';

class SchemaMediator {
  final bool compatibility;

  const SchemaMediator({
    required this.compatibility,
  });

  DataElement convert({
    required final Map<String, Schema>? schemas,
    final String? name,
    required final Schema schema,
  }) =>
      throw UnimplementedError();
// _convert(schemas ?? const {}, name, schema);

// /// todo: schema can be ref
// DataElement _convert(
//   final Map<String, Schema> schemas,
//   final String? name,
//   final Schema schema,
// ) {
//   // format,
//   // defaultValue,
//   // deprecated,
//   // requiredItems,
//   // enumerated,
//   // items,
//   // properties,
//   // uniqueItems,
//
//   if (schema.reference != null) throw AssertionError('non-null reference');
//   final fullType = _extractFullType(schema);
//   final type = fullType.type;
//   final isNullable = fullType.isNullable;
//   switch (type) {
//     case 'null':
//
//     case 'boolean':
//     case 'object':
//     case 'array':
//     case 'number':
//     case 'string':
//     case 'map':
//
//     default:
//       throw AssertionError('unknown type "$type"');
//   }
// }
//
// _FullType _extractFullType(final Schema schema) {
//   final type = schema.type;
//   final nullable = schema.nullable;
//   if (type == null) throw UnimplementedError('type-less schema');
//   if (compatibility) {
//     if (type.isList) throw AssertionError();
//     final single = type.single;
//     if (single == 'null') throw AssertionError();
//     return _FullType(
//       type: single,
//       // todo: check default
//       isNullable: nullable == true,
//     );
//   } else {
//     if (nullable != null) throw AssertionError();
//     final set = type.list.toSet();
//     if (set.isEmpty) {
//       throw UnimplementedError('type-less schema');
//     } else if (set.length == 1 || (set.length == 2 && set.contains('null'))) {
//       return _FullType(
//         type:
//             set.length == 1 ? set.first : (Set.of(set)..remove('null')).first,
//         isNullable: set.contains('null'),
//       );
//     } else {
//       throw UnimplementedError('multi-type schema');
//     }
//   }
// }
}

// class _FullType {
//   final String type;
//   final bool isNullable;
//
//   const _FullType({
//     required this.type,
//     required this.isNullable,
//   });
// }
//
// extension _SchemaReferenceExt on Reference<Schema> {
//   /// get schema name for a schema reference
//   String get schemaName => ref.removeFromStart('#components/schemas/');
// }
