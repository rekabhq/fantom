import 'package:fantom/src/mediator/model/schema/schema_model.dart';

class SchemaValueGenerator {
  const SchemaValueGenerator();

  String generate(
    final DataElement element, {
    required final Object? value,
  }) {
    if (value == null) {
      if (!element.isNullable) throw AssertionError('bad types');
      return 'null';
    } else {
      return element.match(
        boolean: (boolean) {
          // ex. "true"
          if (value is! bool) throw AssertionError('bad types');
          return _primitive(value);
        },
        object: (object) {
          if (value is! Map<String, dynamic>) throw AssertionError('bad types');
          if (object.format == ObjectDataElementFormat.map) {
            // ex. <String, int>{'a': 12}
            final additionalProperties = object.additionalProperties!;
            final sub = object.additionalProperties!.type;
            if (sub == null) {
              throw UnimplementedError('incalculable sub type for map');
            }
            final joined = value.entries
                .map((e) {
                  return _string(e.key) +
                      ': ' +
                      // recursive call:
                      generate(additionalProperties, value: e.value);
                })
                .toList()
                .join(', ');
            return '<String, $sub>{$joined}';
          } else {
            // ex. User.fromJson(<String, int>{'name': 'john'})
            // note: we have handled `null` value so no need for `User?`
            final additionalProperties = object.additionalProperties;
            final name = object.name;
            if (name == null) {
              throw UnimplementedError('anonymous objects are not supported');
            }
            final properties = Map.fromEntries(
              object.properties.map((e) => MapEntry(e.name, e)).toList(),
            );
            final joined = value.entries
                .map((e) {
                  final DataElement item;
                  if (properties.containsKey(e.key)) {
                    item = properties[e.key]!.item;
                  } else {
                    if (additionalProperties == null) {
                      throw AssertionError(
                        'non-additive object with additional fields',
                      );
                    } else {
                      item = additionalProperties;
                    }
                  }
                  return _string(e.key) +
                      ': ' +
                      // recursive call:
                      generate(item, value: e.value);
                })
                .toList()
                .join(', ');
            // todo: fromJson ?
            return 'User.fromJson(<String, dynamic>{$joined})';
          }
        },
        array: (array) {
          // ex. <int>[1,2,3]
          // ex. <int?>{1,2,3}
          // ex. <List<int>>[[1,2],[3,4]]
          if (value is! List<dynamic>) throw AssertionError('bad types');
          final sub = array.items.type;
          if (sub == null) {
            throw UnimplementedError('Incalculable sub type for array');
          }
          // both set and list are stored as list in json and yaml:
          final joined = value
              // recursive call:
              .map((e) => generate(array.items, value: e))
              .toList()
              .join(', ');
          return '<$sub>' + (array.isUniqueItems ? '{$joined}' : '[$joined]');
        },
        integer: (integer) {
          // ex. "1"
          if (value is! int) throw AssertionError('bad types');
          return _primitive(value);
        },
        number: (number) {
          // ex. "1.5"
          // or "1" if type is num
          if (number.isFloat) {
            if (value is! double) throw AssertionError('bad types');
          } else {
            if (value is! num) throw AssertionError('bad types');
          }
          return _primitive(value);
        },
        string: (string) {
          if (string.format == StringDataElementFormat.plain) {
            // ex. "'hello'"
            if (value is! String) throw AssertionError('bad types');
            return _string(value);
          } else {
            // todo: no plain string ?
            throw UnimplementedError('only plain string type is supported');
          }
        },
        untyped: (untyped) {
          throw UnimplementedError(
            'default values for untyped elements are not supported.',
          );
        },
      );
    }
  }

  /// primitive to string
  String _primitive(Object value) => '$value';

  /// string to string
  String _string(Object value) => "'$value'";
}
