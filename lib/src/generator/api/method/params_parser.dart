import 'package:fantom/src/generator/components/components.dart';
import 'package:fantom/src/generator/components/components_registrey.dart';
import 'package:fantom/src/generator/parameter/parameter_class_generator.dart';
import 'package:fantom/src/reader/model/model.dart';

/// should create a metaData object (which is yet to be decided what it is) that explains everything about the parameters
/// of this method in a way that it can be easily used to generate parameters for our method
///
class MethodParamsParser {
  MethodParamsParser({required this.parameterClassGenerator});

  final ParameterClassGenerator parameterClassGenerator;

  OpenApi get openApi => parameterClassGenerator.openApi;

  List<GeneratedParameterComponent> parseParams(
    List<ReferenceOr<Parameter>> operationParameters,
    String nameSeed, {
    List<GeneratedParameterComponent>? pathParameterComponents,
  }) {
    final generatedParameters = <GeneratedParameterComponent>[];

    // convert operation parameters to generated components
    for (final item in operationParameters) {
      final paramComponent = getGeneratedParameterComponent(nameSeed, item);

      if (item.isValue) {
        registerGeneratedComponentWithoutRef(paramComponent);
      }

      generatedParameters.add(paramComponent);
    }

    // convert path parameters to generated components
    if (pathParameterComponents != null) {
      for (var item in pathParameterComponents) {
        bool isOverridden = false;

        for (var operationComponent in generatedParameters) {
          if (_isParamOverridden(operationComponent.source, item.source)) {
            isOverridden = true;
            break;
          }
        }

        if (!isOverridden) generatedParameters.add(item);
      }
    }

    return generatedParameters;
  }

  bool _isParamOverridden(Parameter first, Parameter second) {
    return first.name == second.name && first.location == second.location;
  }

  GeneratedParameterComponent getGeneratedParameterComponent(
    String nameSeed,
    ReferenceOr<Parameter> parameter,
  ) {
    if (parameter.isValue) {
      return parameterClassGenerator.generate(
        openApi,
        parameter.value,
        nameSeed,
      );
    } else if (parameter.isReference) {
      final generatedComponent =
          getGeneratedComponentByRef(parameter.reference.ref);
      if (generatedComponent != null &&
          generatedComponent is GeneratedParameterComponent) {
        return generatedComponent;
      }
      throw StateError(
          'Parameter is Type of Reference, but it is not registered into component registry');
    } else {
      throw Exception('Unknown parameter type');
    }
  }
}
