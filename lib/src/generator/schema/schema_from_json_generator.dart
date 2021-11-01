import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';

class SchemaFromJsonGenerator {
  const SchemaFromJsonGenerator();

  String generateForClass(final ObjectDataElement object) {
    final name = object.name;
    if (name == null) {
      throw UnimplementedError('anonymous objects are not supported');
    }
    if (object.format != ObjectDataElementFormat.object) {
      throw UnimplementedError(
        '"mixed" and "map" objects are not supported : name is ${object.name}',
      );
    }
    for (final property in object.properties) {
      if (property.item.type == null) {
        throw UnimplementedError('anonymous inner objects are not supported');
      }
    }

    return [
      'factory $name.fromJson(Map<String, dynamic> json) => ',
      _inner(object),
      ';',
    ].joinParts();
  }

  String _inner(final ObjectDataElement object) {
    // todo:
    return 'throw 0';
  }
}
