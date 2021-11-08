import 'package:meta/meta.dart';

enum StyleType {
  simple,
  form,
  label,
  matrix,
  spaceDelimited,
  pipeDelimited,
  deepObject,
}

// TODO(payam): we can add support of allowReserved parameter
abstract class ParamSerializer {
  const ParamSerializer();

  const factory ParamSerializer.simple() = SimpleSerializer;

  StyleType get style;

  String get separator;
  String get styleChar;

  String serialize({
    required String parameter,
    required dynamic value,
    bool explode = false,
  });

  @protected
  String serializePrimitive({
    required String parameter,
    required dynamic value,
    bool explode = false,
  });

  @protected
  String serializeArray({
    required String parameter,
    required List value,
    bool explode = false,
  });

  @protected
  String serializeObject({
    required String parameter,
    required Map<String, dynamic> value,
    bool explode = false,
  });

  bool isPrimitive(dynamic value) =>
      value is String || value is num || value is bool;

  bool isArray(dynamic value) => value is List;

  bool isPrimitiveArray(dynamic value) =>
      isArray(value) && value.every(isPrimitive);

  bool isObject(dynamic value) => value is Map<String, dynamic>;

  bool isPrimitiveObject(dynamic value) =>
      isObject(value) && value.values.every(isPrimitive);
}

class SimpleSerializer extends ParamSerializer {
  const SimpleSerializer();

  @override
  StyleType get style => StyleType.simple;

  @override
  String get separator => ',';
  @override
  String get styleChar => '';

  @override
  String serialize({
    required String parameter,
    required dynamic value,
    bool explode = false,
  }) {
    if (isPrimitive(value)) {
      return serializePrimitive(
        parameter: parameter,
        value: value,
        explode: explode,
      );
    } else if (isArray(value)) {
      return serializeArray(
        parameter: parameter,
        value: value,
        explode: explode,
      );
    } else if (isObject(value)) {
      return serializeObject(
        parameter: parameter,
        value: value,
        explode: explode,
      );
    } else {
      throw ArgumentError(
        'Unsupported parameter value. name: $parameter, value: $value',
      );
    }
  }

  @override
  String serializePrimitive({
    required String parameter,
    required value,
    bool explode = false,
  }) {
    return value.toString();
  }

  @override
  String serializeArray({
    required String parameter,
    required List value,
    bool explode = false,
  }) {
    if (isPrimitiveArray(value)) {
      return value.join(separator);
    } else {
      return value.map<String>((item) {
        if (isPrimitive(item)) {
          return serializePrimitive(
            parameter: parameter,
            value: item,
            explode: explode,
          );
        } else if (isArray(item)) {
          return serializeArray(
            parameter: parameter,
            value: item,
            explode: explode,
          );
        } else if (isObject(item)) {
          return serializeObject(
            parameter: parameter,
            value: item,
            explode: explode,
          );
        } else {
          throw ArgumentError(
            'Unsupported parameter value. name: $parameter, value: $value',
          );
        }
      }).join(separator);
    }
  }

  @override
  String serializeObject({
    required String parameter,
    required Map<String, dynamic> value,
    bool explode = false,
  }) {
    final explodeSeparator = explode ? '=' : separator;

    if (isPrimitiveObject(value)) {
      return value.entries.map((entry) {
        return '${entry.key}$explodeSeparator${serializePrimitive(
          parameter: parameter,
          value: entry.value,
          explode: explode,
        )}';
      }).join(separator);
    } else {
      return value.entries.map((entry) {
        if (isPrimitive(entry.value)) {
          return '${entry.key}$explodeSeparator${serializePrimitive(
            parameter: parameter,
            value: entry.value,
            explode: explode,
          )}';
        } else if (isArray(entry.value)) {
          return '${entry.key}$explodeSeparator${serializeArray(
            parameter: parameter,
            value: entry.value,
            explode: explode,
          )}';
        } else if (isObject(entry.value)) {
          return '${entry.key}$explodeSeparator${serializeObject(
            parameter: parameter,
            value: entry.value,
            explode: explode,
          )}';
        } else {
          throw ArgumentError(
            'Unsupported parameter value. name: $parameter, value: $value',
          );
        }
      }).join(separator);
    }
  }
}
