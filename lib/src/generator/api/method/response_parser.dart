import 'package:fantom/src/generator/components/component/component.dart';
import 'package:fantom/src/openapi/model/model.dart';

class MethodResponseParser {
  Component parseResponse(Operation operation) {
    //TODO: should Component type to be used as the response type of the api method
    //either the component is already defined which can be fetched using getComponentByRef() method
    //or we should create a new component register it using registerComponent() method and return it from here
    throw UnimplementedError();
  }
}
