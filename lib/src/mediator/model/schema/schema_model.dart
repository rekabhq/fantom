// ignore_for_file: prefer_void_to_null

/// holder for default value
class DefaultValue {
  /// default value
  final Object? value;

  const DefaultValue(this.value);
}

/// information for an enum or constant value
class EnumerationInfo {
  /// name of enum
  ///
  /// if element is not of object type can be same as element name.
  final String? name;

  /// type of elements
  ///
  /// ex. String?
  ///
  /// should be same as element type.
  final String type;

  /// values of enum
  ///
  /// ex. ['hello', 'hi', null]
  final List<Object?> values;

  const EnumerationInfo({
    required this.name,
    required this.type,
    required this.values,
  });
}

/// dart object property.
///
/// ex. required String? id;
class ObjectProperty {
  /// property name
  final String name;

  /// element type
  final DataElement item;

  /// if property is required
  final bool isRequired;

  const ObjectProperty({
    required this.name,
    required this.item,
    required this.isRequired,
  });
}

/// base data element:
///
/// - [NullingDataElement]
/// - [BooleanDataElement]
/// - [ObjectDataElement]
/// - [ArrayDataElement]
/// - [NumberDataElement]
/// - [StringDataElement]
/// - [MapDataElement]
abstract class DataElement {
  const DataElement();

  /// if is present is used for code generated model name,
  /// and is referenced in schema map.
  String? get name;

  /// if is nullable
  bool get isNullable;

  /// if is deprecated
  bool get isDeprecated;

  /// default value if present
  DefaultValue? get defaultValue;

  /// if present provides enumeration information,
  /// if not present means no enumeration.
  EnumerationInfo? get enumeration;

  /// type with nullability sign
  ///
  /// ex. String, String?,
  /// List<String>, List<String?>, List<String?>?
  String get type;

  /// [NullingDataElement]
  const factory DataElement.nulling({
    required String? name,
    required bool isDeprecated,
    required DefaultValue? defaultValue,
    required EnumerationInfo? enumeration,
  }) = NullingDataElement;

  /// [BooleanDataElement]
  const factory DataElement.boolean({
    required String? name,
    required bool isNullable,
    required bool isDeprecated,
    required DefaultValue? defaultValue,
    required EnumerationInfo? enumeration,
  }) = BooleanDataElement;

  /// [ObjectDataElement]
  const factory DataElement.object({
    required String? name,
    required bool isNullable,
    required bool isDeprecated,
    required DefaultValue? defaultValue,
    required EnumerationInfo? enumeration,
    required List<ObjectProperty> properties,
  }) = ObjectDataElement;

  /// [ArrayDataElement]
  const factory DataElement.array({
    required String? name,
    required bool isNullable,
    required bool isDeprecated,
    required DefaultValue? defaultValue,
    required EnumerationInfo? enumeration,
    required DataElement items,
    required bool isUniqueItems,
  }) = ArrayDataElement;

  /// [NumberDataElement]
  const factory DataElement.number({
    required String? name,
    required bool isNullable,
    required bool isDeprecated,
    required DefaultValue? defaultValue,
    required EnumerationInfo? enumeration,
    required bool? isFloat,
  }) = NumberDataElement;

  /// [StringDataElement]
  const factory DataElement.string({
    required String? name,
    required bool isNullable,
    required bool isDeprecated,
    required DefaultValue? defaultValue,
    required EnumerationInfo? enumeration,
  }) = StringDataElement;

  /// [MapDataElement]
  const factory DataElement.map({
    required String? name,
    required bool isNullable,
    required DefaultValue? defaultValue,
    required EnumerationInfo? enumeration,
    required bool isDeprecated,
    required DataElement items,
  }) = MapDataElement;
}

/// Null
class NullingDataElement implements DataElement {
  @override
  final String? name;

  @override
  final bool isNullable = true;

  @override
  final bool isDeprecated;

  @override
  final DefaultValue? defaultValue;

  @override
  final EnumerationInfo? enumeration;

  const NullingDataElement({
    required this.name,
    required this.isDeprecated,
    required this.defaultValue,
    required this.enumeration,
  });

  @override
  String get type {
    final base = 'Null';
    return base;
  }
}

/// bool
class BooleanDataElement implements DataElement {
  @override
  final String? name;

  @override
  final bool isNullable;

  @override
  final bool isDeprecated;

  @override
  final DefaultValue? defaultValue;

  @override
  final EnumerationInfo? enumeration;

  const BooleanDataElement({
    required this.name,
    required this.isNullable,
    required this.isDeprecated,
    required this.defaultValue,
    required this.enumeration,
  });

  @override
  String get type {
    final base = 'bool';
    return base.nullify(isNullable);
  }
}

/// dart object.
///
/// ex. User, Person.
class ObjectDataElement implements DataElement {
  @override
  final String? name;

  @override
  final bool isNullable;

  @override
  final bool isDeprecated;

  @override
  final DefaultValue? defaultValue;

  @override
  final EnumerationInfo? enumeration;

  /// properties
  final List<ObjectProperty> properties;

  const ObjectDataElement({
    required this.name,
    required this.isNullable,
    required this.isDeprecated,
    required this.defaultValue,
    required this.enumeration,
    required this.properties,
  });

  @override
  String get type {
    if (name == null) {
      throw AssertionError();
    } else {
      final base = name!;
      return base.nullify(isNullable);
    }
  }
}

/// List<*> or Set<*>
class ArrayDataElement implements DataElement {
  @override
  final String? name;

  @override
  final bool isNullable;

  @override
  final bool isDeprecated;

  @override
  final DefaultValue? defaultValue;

  @override
  final EnumerationInfo? enumeration;

  /// element type
  final DataElement items;

  /// if is list or set
  final bool isUniqueItems;

  const ArrayDataElement({
    required this.name,
    required this.isNullable,
    required this.isDeprecated,
    required this.defaultValue,
    required this.enumeration,
    required this.items,
    required this.isUniqueItems,
  });

  @override
  String get type {
    final base = isUniqueItems ? 'Set' : 'List';
    final sub = items.type;
    final generic = '$base<$sub>';
    return generic.nullify(isNullable);
  }
}

/// num, integer or double.
class NumberDataElement implements DataElement {
  @override
  final String? name;

  @override
  final bool isNullable;

  @override
  final bool isDeprecated;

  @override
  final DefaultValue? defaultValue;

  @override
  final EnumerationInfo? enumeration;

  /// if not present means no specific details.
  ///
  /// if present, is integer or double.
  final bool? isFloat;

  const NumberDataElement({
    required this.name,
    required this.isNullable,
    required this.isDeprecated,
    required this.defaultValue,
    required this.enumeration,
    required this.isFloat,
  });

  @override
  String get type {
    final base = isFloat == null
        ? 'num'
        : isFloat!
            ? 'double'
            : 'int';
    return base.nullify(isNullable);
  }
}

/// String.
class StringDataElement implements DataElement {
  @override
  final String? name;

  @override
  final bool isNullable;

  @override
  final bool isDeprecated;

  @override
  final DefaultValue? defaultValue;

  @override
  final EnumerationInfo? enumeration;

  const StringDataElement({
    required this.name,
    required this.isNullable,
    required this.isDeprecated,
    required this.defaultValue,
    required this.enumeration,
  });

  @override
  String get type {
    final base = 'String';
    return base.nullify(isNullable);
  }
}

/// Map<String, *>
class MapDataElement implements DataElement {
  @override
  final String? name;

  @override
  final bool isNullable;

  @override
  final bool isDeprecated;

  @override
  final DefaultValue? defaultValue;

  @override
  final EnumerationInfo? enumeration;

  /// value element type
  final DataElement items;

  const MapDataElement({
    required this.name,
    required this.isNullable,
    required this.isDeprecated,
    required this.defaultValue,
    required this.enumeration,
    required this.items,
  });

  @override
  String get type {
    final base = 'Map';
    final subKey = 'String';
    final subValue = items.type;
    final generic = '$base<$subKey, $subValue>';
    return generic.nullify(isNullable);
  }
}

/// Some nullability utilities
extension StringTypeNullablityExt on String {
  String nullify(bool isNullable) => isNullable ? this : '$this?';
}

/// matching data elements
extension DataElementMatching on DataElement {
  R match<R extends Object?>({
    required R Function(NullingDataElement nulling) nulling,
    required R Function(BooleanDataElement boolean) boolean,
    required R Function(ObjectDataElement object) object,
    required R Function(ArrayDataElement array) array,
    required R Function(NumberDataElement number) number,
    required R Function(StringDataElement string) string,
    required R Function(MapDataElement map) map,
  }) {
    final element = this;
    if (element is NullingDataElement) {
      return nulling(element);
    } else if (element is BooleanDataElement) {
      return boolean(element);
    } else if (element is ObjectDataElement) {
      return object(element);
    } else if (element is ArrayDataElement) {
      return array(element);
    } else if (element is NumberDataElement) {
      return number(element);
    } else if (element is StringDataElement) {
      return string(element);
    } else if (element is MapDataElement) {
      return map(element);
    } else {
      throw AssertionError();
    }
  }

  R matchOrElse<R extends Object?>({
    R Function(NullingDataElement nulling)? nulling,
    R Function(BooleanDataElement boolean)? boolean,
    R Function(ObjectDataElement object)? object,
    R Function(ArrayDataElement array)? array,
    R Function(NumberDataElement number)? number,
    R Function(StringDataElement string)? string,
    R Function(MapDataElement map)? map,
    required R Function(DataElement element) orElse,
  }) {
    final element = this;
    if (element is NullingDataElement) {
      return nulling != null ? nulling(element) : orElse(element);
    } else if (element is BooleanDataElement) {
      return boolean != null ? boolean(element) : orElse(element);
    } else if (element is ObjectDataElement) {
      return object != null ? object(element) : orElse(element);
    } else if (element is ArrayDataElement) {
      return array != null ? array(element) : orElse(element);
    } else if (element is NumberDataElement) {
      return number != null ? number(element) : orElse(element);
    } else if (element is StringDataElement) {
      return string != null ? string(element) : orElse(element);
    } else if (element is MapDataElement) {
      return map != null ? map(element) : orElse(element);
    } else {
      throw AssertionError();
    }
  }
}
