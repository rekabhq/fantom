import 'package:fantom/src/reader/model/model.dart';
import 'package:fantom/src/generator/utils/string_utils.dart';

class ReferenceFinder {
  ReferenceFinder({required this.openApi});

  final OpenApi openApi;

  Parameter findParameter(Reference<Parameter> reference) {
    _validateReferencePath(reference, 'parameters', 'Parameter');

    if (openApi.components?.parameters == null) {
      throw AssertionError('Parameters section in component model is empty!');
    }

    final name = reference.ref.removeFromStart('#/components/parameters/');

    final parameter = openApi.components?.parameters![name];

    if (parameter == null) {
      throw AssertionError('Parameter "$name" not found in the components.');
    }

    return parameter.isValue
        ? parameter.value
        : findParameter(parameter.reference);
  }

  RequestBody findRequestBody(Reference<RequestBody> reference) {
    _validateReferencePath(reference, 'requestBodies', 'Request Body');

    if (openApi.components?.requestBodies == null) {
      throw AssertionError(
          'RequestBodies section in component model is empty!');
    }

    final name = reference.ref.removeFromStart('#/components/requestBodies/');

    final requestBody = openApi.components?.requestBodies![name];

    if (requestBody == null) {
      throw AssertionError('Request Body: "$name" not found in the component.');
    }

    return requestBody.isValue
        ? requestBody.value
        : findRequestBody(requestBody.reference);
  }

  Response findResponse(Reference<Response> reference) {
    _validateReferencePath(reference, 'responses', 'Response');

    if (openApi.components?.responses == null) {
      throw AssertionError('Responses section in component model is empty!');
    }

    final name = reference.ref.removeFromStart('#/components/responses/');

    final response = openApi.components?.responses![name];

    if (response == null) {
      throw AssertionError('Request Body: "$name" not found in the component.');
    }

    return response.isValue ? response.value : findResponse(response.reference);
  }

  bool _validateReferencePath(
    Reference reference,
    String subPath,
    String componentName,
  ) {
    if (!reference.ref.startsWith('#/components/')) {
      reference.ref.contains('/$subPath/')
          ? throw AssertionError(
              'bad reference "${reference.ref}". $componentName reference should placed in #/components/$subPath/ path')
          : throw AssertionError(
              'bad reference "${reference.ref}". The reference must be placed in the component section.');
    }

    return true;
  }
}
