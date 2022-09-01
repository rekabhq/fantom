import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/utils/logger.dart';

final dataElementRegistry = DataElementRegistry._();

class DataElementRegistry {
  DataElementRegistry._();

  final _dataElements = <String, DataElement>{};

  bool isRegistered(String key) {
    // Log.debug('checking isRegistered for data element with key=$key');
    return _dataElements.containsKey(key);
  }

  void register(String key, DataElement element) {
    Log.debug('register dataElement with key=$key');
    if (!isRegistered(key)) {
      _dataElements[key] = element;
    }
  }

  DataElement? operator [](String key) {
    // Log.debug('getting data element with key=$key');
    return _dataElements[key];
  }
}
