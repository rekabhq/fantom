import 'package:fantom/src/utils/exceptions.dart';
import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:meta/meta.dart';

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

@visibleForTesting
void clearComponentsRegistry() {
  _globalComponentsRegistery.clearRegistry();
}

class GeneratedComponentsRegistery {
  final Map<String, GeneratedComponent> components = {};
  final Set<GeneratedComponent> unNamedComponents = {};

  void registerGeneratedComponent(String ref, GeneratedComponent component) {
    _validateReference(ref);
    if (components.containsKey(ref)) {
      throw GeneratedComponentAlreadyDefinedException(ref, components[ref]!);
    } else {
      components[ref] = component;
    }
  }

  void registerGeneratedComponentWithoutRef(GeneratedComponent component) {
    unNamedComponents.add(component);
  }

  GeneratedComponent? getGeneratedComponentByRef(String ref) {
    _validateReference(ref);
    return components[ref];
  }

  @visibleForTesting
  void clearRegistry() {
    components.clear();
    unNamedComponents.clear();
  }

  void _validateReference(String ref) {
    if (!ref.startsWith('#/components/')) {
      throw AssertionError(
        'bad reference "$ref". The reference must be placed in the component section. and start with a #/components/',
      );
    }
  }
}
