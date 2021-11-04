import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/response/response_class_generator.dart';
import 'package:fantom/src/reader/model/model.dart';

class MethodResponseParser {
  MethodResponseParser({required this.responseClassGenerator});

  final ResponseClassGenerator responseClassGenerator;

  GeneratedResponsesComponent parseResponses(
    Responses responses,
    String seedName,
  ) {
    final generatedResponses = responseClassGenerator.generateResponses(
      responses,
      seedName,
    );

    if (generatedResponses.isGenerated) {
      registerGeneratedComponentWithoutRef(generatedResponses);
    }

    return generatedResponses;
  }
}
