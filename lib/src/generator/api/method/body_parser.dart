import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/reader/model/model.dart';

class MethodBodyParser {
  GeneratedComponent parseRequestBody(Operation operation) {
    //TODO: should Component type to be used as the response type of the api method
    //either the component is already defined which can be fetched using getGeneratedComponentByRef() method
    //or we should create a new component register it using registerGeneratedComponent() method and return it from here
    throw UnimplementedError();
  }
}
