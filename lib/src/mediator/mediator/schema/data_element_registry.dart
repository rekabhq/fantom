import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/utils/logger.dart';

final dataElementRegistry = DataElementRegistry._();

class DataElementRegistry {
  DataElementRegistry._();

  final _registeredDataElements = <String, DataElement>{};

  final _registeringDataElements = <String>{};

  bool isRegistering(String ref) {
    // Log.debug('checking isRegistered for data element with key=$key');
    return _registeringDataElements.contains(ref);
  }

  void setAsRegistering(String ref) {
    if (ref.isEmpty) return;
    _registeringDataElements.add(ref);
  }

  bool isRegistered(String ref) {
    // Log.debug('checking isRegistered for data element with key=$key');
    return _registeredDataElements.containsKey(ref);
  }

  void register(String ref, DataElement element) {
    if (ref.isEmpty) return;
    Log.debug('register dataElement with key=$ref');
    if (!isRegistered(ref)) {
      _registeredDataElements[ref] = element;
    }
    _registeringDataElements.remove(ref);
  }

  DataElement? operator [](String ref) {
    // Log.debug('getting data element with key=$key');
    return _registeredDataElements[ref];
  }
}
