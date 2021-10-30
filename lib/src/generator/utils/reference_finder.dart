import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';

class ReferenceFinder {
  ReferenceFinder({required this.openApi});

  final OpenApi openApi;

  Parameter findParameter(Reference<Parameter> reference) {
    if (!reference.ref.startsWith('#/components/')) {
      reference.ref.contains('/parameter/')
          ? throw AssertionError(
              'bad reference "${reference.ref}". Parameter reference should placed in #/components/parameter path')
          : throw AssertionError(
              'bad reference "${reference.ref}". The reference must be placed in the component section.');
    }

    if (openApi.components?.parameters == null) {
      throw AssertionError('Parameters section in component model is empty.');
    }

    final name = reference.ref.removeFromStart('#/components/parameter/');

    final parameter = openApi.components?.parameters![name];

    if (parameter == null) {
      throw AssertionError('Parameter "$name" not found in the component.');
    }

    return parameter.isValue
        ? parameter.value
        : findParameter(parameter.reference);
  }

  //TODO: impelment this method
  RequestBody findRequestBody(Reference<RequestBody> reference) {
    throw UnimplementedError();
  }

  //TODO: impelment this method
  Response findResponse(Reference<Response> reference) {
    throw UnimplementedError();
  }
}
