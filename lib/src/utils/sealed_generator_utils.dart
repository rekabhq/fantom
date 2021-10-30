import 'dart:io';

import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:recase/recase.dart';
import 'package:sealed_writer/sealed_writer.dart';

// ManifestItem(
//   name: '$typeName$',
//   shortName: 'sunny',
//   equality: ManifestEquality.identity,
//   fields: [],
// ),
// ManifestItem(
//   name: 'WeatherRainy',
//   shortName: 'rainy',
//   equality: ManifestEquality.identity,
//   fields: [
//     ManifestField(
//       name: 'rain',
//       type: ManifestType(
//         name: 'int',
//         isNullable: false,
//       ),
//     ),
//   ],
// ),

Future generateSealedTypeFromMediaTypes({
  required String name,
  required Map<String, MediaType> mediaTypes,
  required File output,
  required GeneratedSchemaComponent Function(Referenceable<Schema> schema)
      createGeneratedComponentForSchema,
}) async {
  var typeName = ReCase(name).pascalCase;
  final source = Manifest(
    name: typeName,
    items: List.generate(mediaTypes.entries.length, (index) {
      var entry = mediaTypes.entries.toList()[index];
      var subClassTypeName = '$typeName${ReCase(entry.key).pascalCase}';
      var subClassTypeShortName = ReCase(entry.key).pascalCase;
      var mediaType = entry.value;
      var refOrSchema = mediaType.schema!;
      late GeneratedSchemaComponent component;
      if (refOrSchema.isReference) {
        //TODO schema might be refrenciable in that case we must first retrive schema
        //and then get our generatedComponent from componentRegistry because it is already registered there
        throw Exception('WWWWWHATTTTT ???');
      } else {
        // our schema object first needs to be generated and registered
        component = createGeneratedComponentForSchema(refOrSchema);
      }
      return ManifestItem(
        name: subClassTypeName,
        shortName: subClassTypeShortName,
        equality: ManifestEquality.identity,
        fields: [
          ManifestField(
            name: component.dataElement.name!,
            type: ManifestType(
              name: component.dataElement.type!,
              isNullable: component.dataElement.isNullable,
            ),
          )
        ],
      );
    }),
    params: [],
    fields: [],
  );

  // final backward = BackwardWriter(source);
  // var contentBack = backward.write();
  final forward = SourceWriter(source, referToManifest: false);
  var contentForward = forward.write();
  await output.create();
  await output.writeAsString('''

$contentForward

  ''');
}
