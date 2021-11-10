import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';

class SchemaValueGenerator {
  static const noJson = true;

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
          if (value is! Map<String, Object?>) throw AssertionError('bad types');
          final format = object.format;
          if (format == ObjectDataElementFormat.map) {
            // ex. <String, int>{'a': 12}
            final additionalProperties = object.additionalProperties!;
            final sub = additionalProperties.type;
            final joined = value.entries
                .map((e) {
                  return _string(e.key) +
                      ': ' +
                      // recursive call:
                      generate(additionalProperties, value: e.value);
                })
                .toList()
                .joinArgsFull();
            return '<String, $sub>{$joined}';
          } else {
            // ex. User.fromJson(<String, int>{'name': 'john'})
            // note: we have handled `null` value so no need for `User?`
            final additionalProperties = object.additionalProperties;
            final name = object.name;

            final propertiesMap = Map.fromEntries(
              object.properties.map((e) => MapEntry(e.name, e)).toList(),
            );
            if (noJson) {
              final fixedValues = Map.of(value)
                // remove all fixed properties
                ..removeWhere((key, _) => !propertiesMap.containsKey(key));
              final additionalValues = Map.of(value)
                // include all fixed properties
                ..removeWhere((key, _) => propertiesMap.containsKey(key));

              if (additionalValues.isNotEmpty && additionalProperties == null) {
                throw AssertionError(
                  'non-additive object with additional fields',
                );
              }

              if (format == ObjectDataElementFormat.mixed) {
                throw UnimplementedError('mixed objects is not supported');
              }

              return [
                '$name(',
                for (final key in fixedValues.keys)
                  [
                    '$key : ',
                    if (propertiesMap[key]!.isConstructorOptional) 'Optional(',
                    generate(
                      propertiesMap[key]!.item,
                      value: fixedValues[key],
                    ),
                    if (propertiesMap[key]!.isConstructorOptional) ')',
                    ',',
                  ].joinParts(),
                // if (object.format == ObjectDataElementFormat.mixed)
                //   [
                //     'additionalProperties: ',
                //     generate(additionalProperties!, value: additionalValues),
                //     ','
                //   ].joinParts(),
                ')',
              ].joinParts();
            } else {
              final joined = value.entries
                  .map((e) {
                    final DataElement item;
                    if (propertiesMap.containsKey(e.key)) {
                      item = propertiesMap[e.key]!.item;
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
                  .joinArgsFull();
              return '$name.fromJson(<String, Object?>{$joined})';
            }
          }
        },
        array: (array) {
          // ex. <int>[1,2,3]
          // ex. <int?>{1,2,3}
          // ex. <List<int>>[[1,2],[3,4]]
          if (value is! List<Object?>) throw AssertionError('bad types');
          final sub = array.items.type;
          // both set and list are stored as list in json and yaml:
          final joined = value
              // recursive call:
              .map((e) => generate(array.items, value: e))
              .toList()
              .joinArgsFull();
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
          // ex. "'hello'"
          final format = string.format;
          if (format == StringDataElementFormat.binary) {
            throw UnimplementedError('only plain string is supported');
          }

          if (value is! String) throw AssertionError('bad types');
          return _string(value);
        },
        untyped: (untyped) {
          return _untyped(value);
        },
      );
    }
  }

  /// primitive to string
  String _primitive(Object value) => '$value';

  /// string to string
  String _string(Object value) => "'$value'";

  /// untyped element
  ///
  /// todo: add <x> and <String, x> ?
  String _untyped(Object? value) {
    if (value == null) {
      return 'null';
    } else if (value is String) {
      return _string(value);
    } else if (value is num || value is bool) {
      return _primitive(value);
    } else if (value is List<Object?>) {
      // in untyped we don't have sets
      final joined = value
          .map(
            (e) =>
                // recursive call:
                _untyped(e),
          )
          .joinArgsFull();
      return '<Object?>[$joined]';
    } else if (value is Map<String, Object?>) {
      final joined = value.entries
          .map(
            (e) => [
              "'${e.key}': ",
              // recursive call:
              _untyped(e.value),
            ].joinParts(),
          )
          .joinArgsFull();
      return '<String, Object?>{$joined}';
    } else {
      throw AssertionError();
    }
  }
}
