import 'package:fantom/src/utils/exceptions.dart';
import 'package:fantom/src/generator/components/component/generated_components.dart';

void registerGeneratedComponent(String ref, GeneratedComponent component) =>
    _globalComponentsRegistery.registerGeneratedComponent(ref, component);

void registerGeneratedComponentWithoutRef(GeneratedComponent component) =>
    _globalComponentsRegistery.registerGeneratedComponentWithoutRef(component);

GeneratedComponent? getGeneratedComponentByRef(String ref) =>
    _globalComponentsRegistery.getGeneratedComponentByRef(ref);

List<GeneratedComponent> allGeneratedComponents = [
  ..._globalComponentsRegistery.components.values.toList(),
  ..._globalComponentsRegistery.unNamedComponents.toList(),
];

final GeneratedComponentsRegistery _globalComponentsRegistery =
    GeneratedComponentsRegistery();

class GeneratedComponentsRegistery {
  final Map<String, GeneratedComponent> components = {};
  final Set<GeneratedComponent> unNamedComponents = {};

  void registerGeneratedComponent(String ref, GeneratedComponent component) {
    if (components.containsKey(ref)) {
      throw GeneratedComponentAlreadyDefinedException(ref, components[ref]!);
    } else {
      components[ref] = component;
    }
  }

  void registerGeneratedComponentWithoutRef(GeneratedComponent component) {
    unNamedComponents.add(component);
  }

  GeneratedComponent? getGeneratedComponentByRef(String ref) => components[ref];
}
