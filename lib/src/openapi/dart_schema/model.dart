import 'package:fantom/src/openapi/model/model.dart';

import 'generate_mode.dart';

/// base class for Dart json schema models
/// [DType] is mean Dart type that we use for convert our schemas
abstract class DType {
  String? get format;

  Object? get defaultValue;

  bool? get deprecated;

  List<String>? get requiredItems;

  String generateCode(String name, GenerateMode mode);

  DType fromMap(Map<String, dynamic> map);

  DType fromSchema(Schema schema);
}

//TODO: we should create json schema subtypes from [DType]