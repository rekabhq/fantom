import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';

class SchemaClassToJsonGenerator {
  const SchemaClassToJsonGenerator();

  String generate(final ObjectDataElement object) {
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
      'Map<String, dynamic> toJson() => ',
      _inner(object),
      ';',
    ].joinParts();
  }

  // safe for empty objects
  String _inner(final ObjectDataElement object) {
    return [
      '<String, dynamic>{',
      for (final property in object.properties)
        [
          _property(property),
          ',',
        ].joinParts(),
      '}',
    ].joinLines();
  }

  String _property(final ObjectProperty property) {
    final name = property.name;
    final isOptional = property.isFieldOptional;
    final isNullable = property.item.isNullable;

    final n = isOptional
        ? isNullable
            ? '$name!.value!'
            : '$name!.value'
        : isNullable
            ? '$name!'
            : name;

    final logic = property.item.match(
      boolean: (boolean) {
        return n;
      },
      object: (object) {
        if (object.format == ObjectDataElementFormat.map) {
          // todo
          return "'map'";
        } else {
          return '$n.toJson()';
        }
      },
      array: (array) {
        if (array.isUniqueItems) {
          // todo
          return "'set'";
        } else {
          return _wrap(
            _general(array.items),
            n,
          );
        }
      },
      integer: (integer) {
        return n;
      },
      number: (number) {
        return n;
      },
      string: (string) {
        return n;
      },
      untyped: (untyped) {
        throw UnimplementedError(
          'default values for untyped elements are not supported.',
        );
      },
    );

    return [
      if (isOptional) 'if ($name != null) ',
      "'$name' : ",
      if (isNullable)
        [
          name,
          if (isOptional) '!.value',
          ' == null ? null : ',
        ].joinParts(),
      logic,
    ].joinParts();
  }

  String _wrap(final String code, final String arg) {
    return '((json) => $code)($arg)';
  }

  String _general(final DataElement element) {
    // todo
    return "'${element.type}'";
  }
}
