import 'package:equatable/equatable.dart';

/// holder for default value
class DefaultValue with EquatableMixin {
  /// default value
  final Object? value;

  const DefaultValue({
    required this.value,
  });

  @override
  List<Object?> get props => [
        value,
      ];

  @override
  String toString() => 'DefaultValue{value: $value}';
}

/// information for an enum or constant value
class Enumeration with EquatableMixin {
  /// values of enum
  ///
  /// ex. ['hello', 'hi', null]
  final List<Object?> values;

  const Enumeration({
    required this.values,
  });

  @override
  List<Object?> get props => [
        values,
      ];

  @override
  String toString() => 'Enumeration{values: $values}';
}

/// dart object property.
///
/// ex. required String? id;
class ObjectProperty with EquatableMixin {
  /// property name
  final String name;

  /// element type
  final DataElement item;

  /// if property is required
  final bool isRequired;

  const ObjectProperty({
    required this.name,
    required this.item,
    this.isRequired = false,
  });

  @override
  List<Object?> get props => [
        name,
        item,
        isRequired,
      ];

  @override
  String toString() => 'ObjectProperty{name: $name, item: $item, '
      'isRequired: $isRequired}';
}

/// format of [ObjectDataElement].
enum ObjectDataElementFormat {
  /// dart object, like User.
  ///
  /// can or can not accept additional fields.
  /// should check [ObjectDataElement.isAdditionalPropertiesAllowed].
  ///
  /// properties can be empty.
  /// should check [ObjectDataElement.properties].
  object,

  /// Map<String, *>.
  ///
  /// must accept additional fields.
  /// [ObjectDataElement.isAdditionalPropertiesAllowed] is true.
  map,

  /// dart object which can have additional fields
  /// like a map.
  ///
  /// must accept additional fields.
  /// [ObjectDataElement.isAdditionalPropertiesAllowed] is true.
  mixed,
}

/// format of [StringDataElement].
enum StringDataElementFormat {
  /// string
  plain,

  /// base 64
  byte,

  /// binary stream or list
  binary,

  /// date
  date,

  /// date-time
  dateTime,
}

/// base data element:
///
/// - [BooleanDataElement]
/// - [ObjectDataElement]
/// - [ArrayDataElement]
/// - [NumberDataElement]
/// - [IntegerDataElement]
/// - [StringDataElement]
/// - [UntypedDataElement]
abstract class DataElement {
  const DataElement();

  /// if is present is used for code generated model name,
  /// and is referenced in schema map.
  String get name;

  /// if is nullable
  ///
  /// note for schema:
  /// A true value adds "null" to the allowed type specified by the type
  /// keyword, only if type is explicitly defined within the same Schema Object.
  /// Other Schema Object constraints retain their defined behavior,
  /// and therefore may disallow the use of null as a value.
  /// A false value leaves the specified or default type unmodified.
  /// The default value is false.
  bool get isNullable;

  /// if is deprecated
  bool get isDeprecated;

  /// default value if present
  DefaultValue? get defaultValue;

  /// if present provides enumeration information,
  /// if not present means no enumeration.
  Enumeration? get enumeration;

  /// [BooleanDataElement]
  const factory DataElement.boolean({
    required String name,
    bool isNullable,
    bool isDeprecated,
    DefaultValue? defaultValue,
    Enumeration? enumeration,
  }) = BooleanDataElement;

  /// [ObjectDataElement]
  const factory DataElement.object({
    required String name,
    bool isNullable,
    bool isDeprecated,
    DefaultValue? defaultValue,
    Enumeration? enumeration,
    List<ObjectProperty> properties,
    DataElement? additionalProperties,
  }) = ObjectDataElement;

  /// [ArrayDataElement]
  const factory DataElement.array({
    required String name,
    bool isNullable,
    bool isDeprecated,
    DefaultValue? defaultValue,
    Enumeration? enumeration,
    required DataElement items,
    bool isUniqueItems,
  }) = ArrayDataElement;

  /// [IntegerDataElement]
  const factory DataElement.integer({
    required String name,
    bool isNullable,
    bool isDeprecated,
    DefaultValue? defaultValue,
    Enumeration? enumeration,
  }) = IntegerDataElement;

  /// [NumberDataElement]
  const factory DataElement.number({
    required String name,
    bool isNullable,
    bool isDeprecated,
    DefaultValue? defaultValue,
    Enumeration? enumeration,
    bool isFloat,
  }) = NumberDataElement;

  /// [StringDataElement]
  const factory DataElement.string({
    required String name,
    bool isNullable,
    bool isDeprecated,
    DefaultValue? defaultValue,
    Enumeration? enumeration,
    StringDataElementFormat format,
  }) = StringDataElement;

  /// [UntypedDataElement]
  const factory DataElement.untyped({
    required String name,
    bool isNullable,
    bool isDeprecated,
    DefaultValue? defaultValue,
    Enumeration? enumeration,
  }) = UntypedDataElement;
}

/// bool
class BooleanDataElement with EquatableMixin implements DataElement {
  @override
  final String name;

  @override
  final bool isNullable;

  @override
  final bool isDeprecated;

  @override
  final DefaultValue? defaultValue;

  @override
  final Enumeration? enumeration;

  const BooleanDataElement({
    required this.name,
    this.isNullable = false,
    this.isDeprecated = false,
    this.defaultValue,
    this.enumeration,
  });

  @override
  List<Object?> get props => [
        name,
        isNullable,
        isDeprecated,
        defaultValue,
        enumeration,
      ];

  @override
  String toString() => 'BooleanDataElement{name: $name, '
      'isNullable: $isNullable, isDeprecated: $isDeprecated, '
      'defaultValue: $defaultValue, enumeration: $enumeration}';
}

/// dart-object or Map<String, *>.
///
/// ex. User, Person?.
/// ex. Map<String, User>, Map<String, String>?.
///
/// note for schema:
/// additionalProperties:
/// Value can be boolean or object.
/// Consistent with JSON Schema, additionalProperties defaults to true.
///
/// note for json schema:
/// properties:
/// The value of "properties" MUST be an object.
/// Each value of this object MUST be a valid JSON Schema.
/// Omitting this keyword has the same assertion behavior as an empty object.
/// additionalProperties:
/// The value of "additionalProperties" MUST be a valid JSON Schema.
/// Validation with "additionalProperties" applies only to the child values
/// of instance names that do not appear in the annotation results of
/// either "properties" or "patternProperties".
/// Omitting this keyword has the same assertion behavior as an empty schema.
///
/// so for additional properties:
/// if null then equivalent to true.
/// if false then no additional is allowed.
/// if true then equivalent to empty schema.
/// if schema then should be parsed.
class ObjectDataElement with EquatableMixin implements DataElement {
  /// objects can not be name-less
  @override
  final String name;

  @override
  final bool isNullable;

  @override
  final bool isDeprecated;

  @override
  final DefaultValue? defaultValue;

  @override
  final Enumeration? enumeration;

  /// properties
  final List<ObjectProperty> properties;

  /// additionalProperties
  ///
  /// if is null then means that additional properties is note allowed.
  final DataElement? additionalProperties;

  const ObjectDataElement({
    required this.name,
    this.isNullable = false,
    this.isDeprecated = false,
    this.defaultValue,
    this.enumeration,
    this.properties = const [],
    this.additionalProperties,
  });

  @override
  List<Object?> get props => [
        name,
        isNullable,
        isDeprecated,
        defaultValue,
        enumeration,
        properties,
        additionalProperties,
      ];

  @override
  String toString() => 'ObjectDataElement{name: $name, '
      'isNullable: $isNullable, isDeprecated: $isDeprecated, '
      'defaultValue: $defaultValue, enumeration: $enumeration, '
      'properties: $properties, '
      'additionalProperties: $additionalProperties}';
}

/// List<*> or Set<*>
///
/// note for schema: items MUST be present if the type is array.
class ArrayDataElement with EquatableMixin implements DataElement {
  @override
  final String name;

  @override
  final bool isNullable;

  @override
  final bool isDeprecated;

  @override
  final DefaultValue? defaultValue;

  @override
  final Enumeration? enumeration;

  /// element type
  final DataElement items;

  /// if is list or set ?
  final bool isUniqueItems;

  const ArrayDataElement({
    required this.name,
    this.isNullable = false,
    this.isDeprecated = false,
    this.defaultValue,
    this.enumeration,
    required this.items,
    this.isUniqueItems = false,
  });

  @override
  List<Object?> get props => [
        name,
        isNullable,
        isDeprecated,
        defaultValue,
        enumeration,
        items,
        isUniqueItems,
      ];

  @override
  String toString() => 'ArrayDataElement{name: $name, '
      'isNullable: $isNullable, isDeprecated: $isDeprecated, '
      'defaultValue: $defaultValue, enumeration: $enumeration, '
      'items: $items, isUniqueItems: $isUniqueItems}';
}

/// int.
class IntegerDataElement with EquatableMixin implements DataElement {
  @override
  final String name;

  @override
  final bool isNullable;

  @override
  final bool isDeprecated;

  @override
  final DefaultValue? defaultValue;

  @override
  final Enumeration? enumeration;

  const IntegerDataElement({
    required this.name,
    this.isNullable = false,
    this.isDeprecated = false,
    this.defaultValue,
    this.enumeration,
  });

  @override
  List<Object?> get props => [
        name,
        isNullable,
        isDeprecated,
        defaultValue,
        enumeration,
      ];

  @override
  String toString() => 'NumberDataElement{name: $name, '
      'isNullable: $isNullable, isDeprecated: $isDeprecated, '
      'defaultValue: $defaultValue, enumeration: $enumeration}';
}

/// num, double.
class NumberDataElement with EquatableMixin implements DataElement {
  @override
  final String name;

  @override
  final bool isNullable;

  @override
  final bool isDeprecated;

  @override
  final DefaultValue? defaultValue;

  @override
  final Enumeration? enumeration;

  /// is double or num ?
  final bool isFloat;

  const NumberDataElement({
    required this.name,
    this.isNullable = false,
    this.isDeprecated = false,
    this.defaultValue,
    this.enumeration,
    this.isFloat = false,
  });

  @override
  List<Object?> get props => [
        name,
        isNullable,
        isDeprecated,
        defaultValue,
        enumeration,
        isFloat,
      ];

  @override
  String toString() => 'NumberDataElement{name: $name, '
      'isNullable: $isNullable, isDeprecated: $isDeprecated, '
      'defaultValue: $defaultValue, enumeration: $enumeration, '
      'format: $isFloat}';
}

/// String.
class StringDataElement with EquatableMixin implements DataElement {
  @override
  final String name;

  @override
  final bool isNullable;

  @override
  final bool isDeprecated;

  @override
  final DefaultValue? defaultValue;

  @override
  final Enumeration? enumeration;

  /// format.
  ///
  /// see: [StringDataElementFormat].
  final StringDataElementFormat format;

  const StringDataElement({
    required this.name,
    this.isNullable = false,
    this.isDeprecated = false,
    this.defaultValue,
    this.enumeration,
    this.format = StringDataElementFormat.plain,
  });

  @override
  List<Object?> get props => [
        name,
        isNullable,
        isDeprecated,
        defaultValue,
        enumeration,
        format,
      ];

  @override
  String toString() => 'StringDataElement{name: $name, '
      'isNullable: $isNullable, isDeprecated: $isDeprecated, '
      'defaultValue: $defaultValue, enumeration: $enumeration, '
      'format: $format}';
}

/// dynamic
///
/// it's type is Object or Object?
///
/// it means any possible json value ... (?)
class UntypedDataElement with EquatableMixin implements DataElement {
  @override
  final String name;

  @override
  final bool isNullable;

  @override
  final bool isDeprecated;

  @override
  final DefaultValue? defaultValue;

  @override
  final Enumeration? enumeration;

  const UntypedDataElement({
    required this.name,
    this.isNullable = true,
    this.isDeprecated = false,
    this.defaultValue,
    this.enumeration,
  });

  @override
  List<Object?> get props => [
        name,
        isNullable,
        isDeprecated,
        defaultValue,
        enumeration,
      ];

  @override
  String toString() => 'UntypedDataElement{name: $name, '
      'isNullable: $isNullable, isDeprecated: $isDeprecated, '
      'defaultValue: $defaultValue, enumeration: $enumeration}';
}

/// matching data elements
extension DataElementMatchingExt on DataElement {
  R match<R extends Object?>({
    required R Function(BooleanDataElement boolean) boolean,
    required R Function(ObjectDataElement object) object,
    required R Function(ArrayDataElement array) array,
    required R Function(IntegerDataElement integer) integer,
    required R Function(NumberDataElement number) number,
    required R Function(StringDataElement string) string,
    required R Function(UntypedDataElement untyped) untyped,
  }) {
    final element = this;
    if (element is BooleanDataElement) {
      return boolean(element);
    } else if (element is ObjectDataElement) {
      return object(element);
    } else if (element is ArrayDataElement) {
      return array(element);
    } else if (element is IntegerDataElement) {
      return integer(element);
    } else if (element is NumberDataElement) {
      return number(element);
    } else if (element is StringDataElement) {
      return string(element);
    } else if (element is UntypedDataElement) {
      return untyped(element);
    } else {
      throw AssertionError();
    }
  }

  R matchOrElse<R extends Object?>({
    R Function(BooleanDataElement boolean)? boolean,
    R Function(ObjectDataElement object)? object,
    R Function(ArrayDataElement array)? array,
    R Function(IntegerDataElement integer)? integer,
    R Function(NumberDataElement number)? number,
    R Function(StringDataElement string)? string,
    R Function(UntypedDataElement untyped)? untyped,
    required R Function(DataElement element) orElse,
  }) {
    final element = this;
    if (element is BooleanDataElement) {
      return boolean != null ? boolean(element) : orElse(element);
    } else if (element is ObjectDataElement) {
      return object != null ? object(element) : orElse(element);
    } else if (element is ArrayDataElement) {
      return array != null ? array(element) : orElse(element);
    } else if (element is IntegerDataElement) {
      return integer != null ? integer(element) : orElse(element);
    } else if (element is NumberDataElement) {
      return number != null ? number(element) : orElse(element);
    } else if (element is StringDataElement) {
      return string != null ? string(element) : orElse(element);
    } else if (element is UntypedDataElement) {
      return untyped != null ? untyped(element) : orElse(element);
    } else {
      throw AssertionError();
    }
  }
}

/// casting data elements
extension DataElementCastingExt on DataElement {
  bool get isBooleanDataElement => this is BooleanDataElement;

  bool get isObjectDataElement => this is ObjectDataElement;

  bool get isArrayDataElement => this is ArrayDataElement;

  bool get isNumberDataElement => this is NumberDataElement;

  bool get isStringDataElement => this is StringDataElement;

  bool get isUntypedDataElement => this is UntypedDataElement;

  BooleanDataElement get asBooleanDataElement => this as BooleanDataElement;

  ObjectDataElement get asObjectDataElement => this as ObjectDataElement;

  ArrayDataElement get asArrayDataElement => this as ArrayDataElement;

  NumberDataElement get asNumberDataElement => this as NumberDataElement;

  StringDataElement get asStringDataElement => this as StringDataElement;

  UntypedDataElement get asUntypedDataElement => this as UntypedDataElement;
}

/// extensions on [DataElement]
extension DataElementUtilityExt on DataElement {
  /// is not nullable.
  bool get isNotNullable => !isNullable;

  /// has default value.
  bool get hasDefaultValue => defaultValue != null;

  /// has not default value.
  bool get hasNotDefaultValue => !hasDefaultValue;

  /// has enum
  bool get isEnumerated => enumeration != null;

  /// has not enum
  bool get isNotEnumerated => !isEnumerated;
}

/// extensions on [DataElement]
extension DataElementEnumNameExt on DataElement {
  /// enum name
  ///
  /// if itself is data class append 'Enum' to it.
  String get enumName {
    final element = this;
    // we generate enum for
    if (element is ObjectDataElement &&
        element.format != ObjectDataElementFormat.map) {
      return '${name}Enum';
    } else {
      return name;
    }
  }
}

/// extensions on [ObjectProperty]
extension ObjectPropertyExt on ObjectProperty {
  /// is not required.
  bool get isNotRequired => !isRequired;

  /// is field optional.
  bool get isFieldOptional => isNotRequired && item.hasNotDefaultValue;

  /// is not field optional.
  bool get isNotFieldOptional => !isFieldOptional;

  /// is constructor optional.
  bool get isConstructorOptional => isNotRequired || item.hasDefaultValue;

  /// is not constructor optional.
  bool get isNotConstructorOptional => !isConstructorOptional;

  /// is constructor required.
  bool get isConstructorRequired => isRequired && item.isNotNullable;
}

/// extensions on [ObjectDataElement].
extension ObjectDataElementFormatExt on ObjectDataElement {
  /// format.
  ///
  /// see: [ObjectDataElementFormat].
  ObjectDataElementFormat get format {
    // is null or untyped:
    if (additionalProperties is UntypedDataElement?) {
      return ObjectDataElementFormat.object;
    } else {
      if (properties.isEmpty) {
        return ObjectDataElementFormat.map;
      } else {
        return ObjectDataElementFormat.mixed;
      }
    }
  }

  /// if is additional properties allowed.
  bool get isAdditionalPropertiesAllowed => additionalProperties != null;
}

/// extensions on [ObjectDataElement].
extension ObjectDataElementTypeExt on ObjectDataElement {
  /// the type of map used.
  ///
  /// with nullability.
  ///
  /// may include enum.
  String? get mapTypeOrNull {
    return mapTypeNNOrNull?.withNullability(isNullable);
  }

  /// the type of map used.
  ///
  /// without nullability.
  ///
  /// may include enum.
  String? get mapTypeNNOrNull {
    if (isAdditionalPropertiesAllowed) {
      final sub = additionalProperties!.type;
      return 'Map<String, $sub>';
    } else {
      return null;
    }
  }

  /// the type of map used.
  ///
  /// with nullability.
  ///
  /// sub type will be raw.
  String? get rawMapTypeOrNull {
    return rawMapTypeNNOrNull?.withNullability(isNullable);
  }

  /// the type of map used.
  ///
  /// without nullability.
  ///
  /// sub type will be raw.
  String? get rawMapTypeNNOrNull {
    if (isAdditionalPropertiesAllowed) {
      final sub = additionalProperties!.rawType;
      return 'Map<String, $sub>';
    } else {
      return null;
    }
  }

  /// the type of map used.
  ///
  /// with nullability.
  ///
  /// sub type will be recursively raw.
  String? get deepRawMapTypeOrNull {
    return deepRawMapTypeNNOrNull?.withNullability(isNullable);
  }

  /// the type of map used.
  ///
  /// without nullability.
  ///
  /// sub type will be recursively raw.
  String? get deepRawMapTypeNNOrNull {
    if (isAdditionalPropertiesAllowed) {
      final sub = additionalProperties!.deepRawType;
      return 'Map<String, $sub>';
    } else {
      return null;
    }
  }
}

/// extensions on [DataElement].
extension DataElementTypeExt on DataElement {
  /// type possibly with nullability sign.
  ///
  /// can be enum.
  String get type {
    if (isEnumerated) {
      return enumName;
    } else {
      return rawType;
    }
  }

  /// raw type with nullability sign.
  ///
  /// can not be enum.
  ///
  /// internal types may be enums.
  ///
  /// ex. String, String?,
  /// List<String>, List<String?>, List<String?>?,
  /// User, User?,
  ///
  /// it can be `Object` or `Object?` if we have an untyped object.
  String get rawType => rawTypeNN.withNullability(isNullable);

  /// raw type without nullability sign.
  ///
  /// can not be enum.
  ///
  /// internal types may be enums.
  ///
  /// ex. String, NOT String?,
  /// List<String>, List<String?>, NOT List<String?>?,
  /// User, NOT User?,
  ///
  /// it can be `Object` if we have an untyped object.
  String get rawTypeNN => match(
        boolean: (boolean) {
          return 'bool';
        },
        object: (object) {
          if (object.format == ObjectDataElementFormat.map) {
            final sub = object.additionalProperties!.type;
            return 'Map<String, $sub>';
          } else {
            return name;
          }
        },
        array: (array) {
          final sub = array.items.type;
          if (array.isUniqueItems) {
            return 'Set<$sub>';
          } else {
            return 'List<$sub>';
          }
        },
        integer: (integer) {
          return 'int';
        },
        number: (number) {
          if (number.isFloat) {
            return 'double';
          } else {
            return 'num';
          }
        },
        string: (string) {
          return _stringRawTypeNN(string);
        },
        untyped: (untyped) {
          return 'Object';
        },
      );

  /// recursive raw type with nullability sign.
  ///
  /// can not be enum.
  ///
  /// internal types can not be enums.
  String get deepRawType => deepRawTypeNN.withNullability(isNullable);

  /// recursive raw type without nullability sign.
  ///
  /// can not be enum.
  ///
  /// internal types can not be enums.
  String get deepRawTypeNN => match(
        boolean: (boolean) {
          return 'bool';
        },
        object: (object) {
          if (object.format == ObjectDataElementFormat.map) {
            final sub = object.additionalProperties!.deepRawType;
            return 'Map<String, $sub>';
          } else {
            return name;
          }
        },
        array: (array) {
          final sub = array.items.deepRawType;
          if (array.isUniqueItems) {
            return 'Set<$sub>';
          } else {
            return 'List<$sub>';
          }
        },
        integer: (integer) {
          return 'int';
        },
        number: (number) {
          if (number.isFloat) {
            return 'double';
          } else {
            return 'num';
          }
        },
        string: (string) {
          return _stringRawTypeNN(string);
        },
        untyped: (untyped) {
          return 'Object';
        },
      );

  /// string raw type.
  String _stringRawTypeNN(string) {
    switch (string.format) {
      case StringDataElementFormat.plain:
        return 'String';
      case StringDataElementFormat.byte:
        return 'String';
      case StringDataElementFormat.binary:
        return 'MultipartFile';
      case StringDataElementFormat.date:
        return 'DateTime';
      case StringDataElementFormat.dateTime:
        return 'DateTime';
      default:
        throw AssertionError();
    }
  }
}

/// internal utilities for strings
extension _StringNullabilityExt on String {
  /// add nullability if needed.
  String withNullability(bool isNullable) => isNullable ? '$this?' : this;
}

/// extensions on [DataElement]
extension DataElementGenerationExt on DataElement {
  /// if data element should be generated
  bool get isGeneratable => match(
        boolean: (boolean) => false,
        object: (object) => object.format != ObjectDataElementFormat.map,
        array: (array) => false,
        integer: (integer) => false,
        number: (number) => false,
        string: (string) => false,
        untyped: (untyped) => false,
      );
}
