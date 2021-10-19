import 'package:fantom/src/generator/utils/string_utils.dart';
import 'package:fantom/src/openapi/model/model.dart';

/// supports `3.1` and partially `>=3.0 <3.1`.
class SchemaGenerator {
  const SchemaGenerator();

  String generate(final Map<String, Schema> schemas) =>
      _generate(schemas).joinMethods();

  List<String> _generate(final Map<String, Schema> schemas) => schemas.keys
      .map((String schemaName) => _generateOne(schemas, schemaName))
      .whereType<String>()
      .toList();

  // todo check for nullable field
  String? _generateOne(final Map<String, Schema> schemas, String schemaName) {
    final schema = schemas['name']!;

    if (schema.type != null) {
      if (schema.type!.isSingle || schema.type!.list.length == 1) {
        final upType = schema.type!.isSingle
            ? schema.type!.single
            : schema.type!.list.first;
        if (upType == 'object') {
          if (schema.properties != null && schema.properties!.isNotEmpty) {
            final buff1 = StringBuffer();
            final buff2 = StringBuffer();
            final buff3 = StringBuffer();
            for (final propertyEntry in schema.properties!.entries) {
              final propertyName = propertyEntry.key;
              final property = propertyEntry.value;
              final isRequired = schema.requiredItems != null
                  ? schema.requiredItems!.contains(propertyName)
                  : false;
              final hasDefaultValue = property.defaultValue != null;
              if (isRequired ^ hasDefaultValue) {
                throw AssertionError();
              }
              if (property.type != null) {
                if (property.reference != null) {
                  // todo
                  throw UnimplementedError();
                } else {
                  if (property.type!.isSingle ||
                      property.type!.list.length == 1) {
                    final type = property.type!.isSingle
                        ? property.type!.single
                        : property.type!.list.first;

                    if (type == 'array') {
                      // todo
                      throw UnimplementedError();
                    } else if (type == 'object') {
                      // todo
                      throw UnimplementedError();
                    } else {
                      String? parsedType;
                      String? defaultValue;
                      switch (type) {
                        case 'string':
                          parsedType = 'String';
                          if (!isRequired) {
                            if (property.defaultValue is String) {
                              defaultValue = "'${property.defaultValue}'";
                            } else {
                              throw AssertionError();
                            }
                          }
                          break;
                        case 'number':
                          if (property.format == 'float' ||
                              property.format == 'double') {
                            parsedType = 'double';
                            if (!isRequired) {
                              if (property.defaultValue is double) {
                                defaultValue = '${property.defaultValue}';
                              } else {
                                throw AssertionError();
                              }
                            }
                          } else {
                            parsedType = 'num';
                            if (!isRequired) {
                              if (property.defaultValue is num) {
                                defaultValue = '${property.defaultValue}';
                              } else {
                                throw AssertionError();
                              }
                            }
                          }
                          break;
                        case 'integer':
                          parsedType = 'int';
                          if (!isRequired) {
                            if (property.defaultValue is int) {
                              defaultValue = '${property.defaultValue}';
                            } else {
                              throw AssertionError();
                            }
                          }
                          break;
                        case 'boolean':
                          parsedType = 'bool';
                          if (!isRequired) {
                            if (property.defaultValue is bool) {
                              defaultValue = '${property.defaultValue}';
                            } else {
                              throw AssertionError();
                            }
                          }
                          break;
                        default:
                          throw UnimplementedError();
                      }
                      buff1.writeln('final $parsedType $propertyName;');
                      if (isRequired) {
                        buff2.writeln(
                          'required Holder\$<$parsedType> $propertyName,',
                        );
                        buff3.writeln(
                          '$propertyName = $propertyName.value,',
                        );
                      } else {
                        buff2.writeln(
                          'Holder\$<$parsedType>? $propertyName,',
                        );
                        buff3.writeln(
                          '$propertyName = $propertyName != null ? '
                          '$propertyName.value : $defaultValue,',
                        );
                      }
                    }
                  } else {
                    if (property.type!.list.contains('null')) {
                      if (property.type!.list.length == 2) {
                        // todo
                        throw UnimplementedError();
                      } else {
                        throw UnimplementedError();
                      }
                    } else {
                      throw UnimplementedError();
                    }
                  }
                }
              } else {
                if (property.reference != null) {
                  throw UnimplementedError();
                } else {
                  throw UnimplementedError();
                }
              }
            }
            // should remove trailing ',' for buff3 and add a ';'
            return [
              'class $schemaName {',
              buff1.toString(),
              '$schemaName({',
              buff2.toString(),
              '}) : ',
              buff3.toString(),
              ';', // we have now ',\n;\n'
              '}',
            ].joinLines().replaceFirst(',\n;', ';');
          } else {
            // empty class !
            return [
              'class $schemaName {',
              '$schemaName();',
              '}',
            ].joinLines();
          }
        } else {
          return null;
        }
      } else {
        throw UnimplementedError();
      }
    } else {
      throw UnimplementedError();
    }
  }
}

class FieldDetails {
  final bool isRequired;
  final String name;
  final String type;
  final String? defaultValue;

  const FieldDetails({
    required this.isRequired,
    required this.name,
    required this.type,
    required this.defaultValue,
  });
}

extension SchemaReferenceExt on Reference<Schema> {
  /// get schema name for a schema reference
  String get schemaName => ref.removeFromStart('#components/schemas/');
}
