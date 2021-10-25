// ignore_for_file: prefer_void_to_null

import 'package:equatable/equatable.dart';

/// holder for default value
class DefaultValue with EquatableMixin {
  /// type of elements
  ///
  /// ex. String?
  ///
  /// should be same as element type.
  final String? type;

  /// default value
  final Object? value;

  const DefaultValue({
    required this.type,
    required this.value,
  });

  @override
  List<Object?> get props => [
        type,
        value,
      ];
}

/// information for an enum or constant value
class EnumerationInfo with EquatableMixin {
  /// name of enum
  final String? name;

  /// type of elements
  ///
  /// ex. String?
  ///
  /// should be same as element type.
  final String? type;

  /// values of enum
  ///
  /// ex. ['hello', 'hi', null]
  final List<Object?> values;

  const EnumerationInfo({
    required this.name,
    required this.type,
    required this.values,
  });

  @override
  List<Object?> get props => [
        name,
        type,
        values,
      ];
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
    required this.isRequired,
  });

  @override
  List<Object?> get props => [
        name,
        item,
        isRequired,
      ];
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

  /// type with nullability sign
  ///
  /// ex. String, String?,
  /// List<String>, List<String?>, List<String?>?,
  /// User, User?,
  ///
  /// it can be null if we have an unnamed object
  String? get type;

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

  /// [NullingDataElement]
  const factory DataElement.nulling({
    required String type,
    required String? name,
    required bool isDeprecated,
    required DefaultValue? defaultValue,
    required EnumerationInfo? enumeration,
  }) = NullingDataElement;

  /// [BooleanDataElement]
  const factory DataElement.boolean({
    required String type,
    required String? name,
    required bool isNullable,
    required bool isDeprecated,
    required DefaultValue? defaultValue,
    required EnumerationInfo? enumeration,
  }) = BooleanDataElement;

  /// [ObjectDataElement]
  const factory DataElement.object({
    required String? type,
    required String? name,
    required bool isNullable,
    required bool isDeprecated,
    required DefaultValue? defaultValue,
    required EnumerationInfo? enumeration,
    required List<ObjectProperty> properties,
    required DataElement? additionalItems,
  }) = ObjectDataElement;

  /// [ArrayDataElement]
  const factory DataElement.array({
    required String type,
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
    required String type,
    required String? name,
    required bool isNullable,
    required bool isDeprecated,
    required DefaultValue? defaultValue,
    required EnumerationInfo? enumeration,
    required bool? isFloat,
  }) = NumberDataElement;

  /// [StringDataElement]
  const factory DataElement.string({
    required String type,
    required String? name,
    required bool isNullable,
    required bool isDeprecated,
    required DefaultValue? defaultValue,
    required EnumerationInfo? enumeration,
  }) = StringDataElement;

  /// [MapDataElement]
  const factory DataElement.map({
    required String type,
    required String? name,
    required bool isNullable,
    required DefaultValue? defaultValue,
    required EnumerationInfo? enumeration,
    required bool isDeprecated,
    required DataElement items,
  }) = MapDataElement;

  /// [UntypedDataElement]
  const factory DataElement.untyped({
    required String type,
    required String? name,
    required bool isDeprecated,
    required DefaultValue? defaultValue,
    required EnumerationInfo? enumeration,
  }) = UntypedDataElement;
}

/// Null
class NullingDataElement with EquatableMixin implements DataElement {
  @override
  final String type;

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
    required this.type,
    required this.name,
    required this.isDeprecated,
    required this.defaultValue,
    required this.enumeration,
  });

  @override
  List<Object?> get props => [
        type,
        name,
        isNullable,
        isDeprecated,
        defaultValue,
        enumeration,
      ];
}

/// bool
class BooleanDataElement with EquatableMixin implements DataElement {
  @override
  final String type;

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
    required this.type,
    required this.name,
    required this.isNullable,
    required this.isDeprecated,
    required this.defaultValue,
    required this.enumeration,
  });

  @override
  List<Object?> get props => [
        type,
        name,
        isNullable,
        isDeprecated,
        defaultValue,
        enumeration,
      ];
}

/// dart object.
///
/// ex. User, Person.
class ObjectDataElement with EquatableMixin implements DataElement {
  @override
  final String? type;

  /// objects can not be name-less
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
  ///
  /// if this is empty then additionalItems is null.
  final List<ObjectProperty> properties;

  /// if present, means we have free-form object.
  /// this will specify additional items type.
  /// if not present we have fixed object.
  ///
  /// note: empty objects with additional items are
  /// considered map.
  final DataElement? additionalItems;

  const ObjectDataElement({
    required this.type,
    required this.name,
    required this.isNullable,
    required this.isDeprecated,
    required this.defaultValue,
    required this.enumeration,
    required this.properties,
    required this.additionalItems,
  });

  @override
  List<Object?> get props => [
        type,
        name,
        isNullable,
        isDeprecated,
        defaultValue,
        enumeration,
        properties,
        additionalItems,
      ];
}

/// List<*> or Set<*>
class ArrayDataElement with EquatableMixin implements DataElement {
  @override
  final String type;

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
    required this.type,
    required this.name,
    required this.isNullable,
    required this.isDeprecated,
    required this.defaultValue,
    required this.enumeration,
    required this.items,
    required this.isUniqueItems,
  });

  @override
  List<Object?> get props => [
        type,
        name,
        isNullable,
        isDeprecated,
        defaultValue,
        enumeration,
        items,
        isUniqueItems,
      ];
}

/// num, integer or double.
class NumberDataElement with EquatableMixin implements DataElement {
  @override
  final String type;

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
    required this.type,
    required this.name,
    required this.isNullable,
    required this.isDeprecated,
    required this.defaultValue,
    required this.enumeration,
    required this.isFloat,
  });

  @override
  List<Object?> get props => [
        type,
        name,
        isNullable,
        isDeprecated,
        defaultValue,
        enumeration,
        isFloat,
      ];
}

/// String.
class StringDataElement with EquatableMixin implements DataElement {
  @override
  final String type;

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
    required this.type,
    required this.name,
    required this.isNullable,
    required this.isDeprecated,
    required this.defaultValue,
    required this.enumeration,
  });

  @override
  List<Object?> get props => [
        type,
        name,
        isNullable,
        isDeprecated,
        defaultValue,
        enumeration,
      ];
}

/// Map<String, *>
class MapDataElement with EquatableMixin implements DataElement {
  @override
  final String type;

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
    required this.type,
    required this.name,
    required this.isNullable,
    required this.isDeprecated,
    required this.defaultValue,
    required this.enumeration,
    required this.items,
  });

  @override
  List<Object?> get props => [
        type,
        name,
        isNullable,
        isDeprecated,
        defaultValue,
        enumeration,
        items,
      ];
}

/// dynamic
class UntypedDataElement with EquatableMixin implements DataElement {
  @override
  final String type;

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

  const UntypedDataElement({
    required this.type,
    required this.name,
    required this.isDeprecated,
    required this.defaultValue,
    required this.enumeration,
  });

  @override
  List<Object?> get props => [
        type,
        name,
        isNullable,
        isDeprecated,
        defaultValue,
        enumeration,
      ];
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
    required R Function(UntypedDataElement untyped) untyped,
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
    } else if (element is UntypedDataElement) {
      return untyped(element);
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
    R Function(UntypedDataElement untyped)? untyped,
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
    } else if (element is UntypedDataElement) {
      return untyped != null ? untyped(element) : orElse(element);
    } else {
      throw AssertionError();
    }
  }
}
