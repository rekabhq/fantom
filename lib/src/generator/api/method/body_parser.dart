import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/request_body/requestbody_class_generator.dart';
import 'package:fantom/src/reader/model/model.dart';

class MethodBodyParser {
  MethodBodyParser({required this.bodyClassGenerator});

  final RequestBodyClassGenerator bodyClassGenerator;

  GeneratedRequestBodyComponent parseRequestBody(
    Referenceable<RequestBody> requestBody,
    String seedName,
  ) {
    if (requestBody.isReference) {
      final generatedBody =
          getGeneratedComponentByRef(requestBody.reference.ref);

      if (generatedBody != null &&
          generatedBody is GeneratedRequestBodyComponent) {
        return generatedBody;
      }
      throw StateError(
          'Request Body is Type of Reference, but it is not registered into component registry');
    } else if (requestBody.isValue) {
      final generatedBody =
          bodyClassGenerator.generate(requestBody.value, seedName);

      registerGeneratedComponentWithoutRef(generatedBody);

      return generatedBody;
    } else {
      throw Exception('Unknown RequestBody Referenceable type');
    }
  }
}
