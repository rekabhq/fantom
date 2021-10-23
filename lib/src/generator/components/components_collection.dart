import 'package:fantom/src/exceptions/exceptions.dart';
import 'package:fantom/src/generator/components/component/component.dart';

void registerGeneratedComponent(String ref, GeneratedComponent component) =>
    _globalComponentsCollection.registerGeneratedComponent(ref, component);

GeneratedComponent? getGeneratedComponentByRef(String ref) =>
    _globalComponentsCollection.getGeneratedComponentByRef(ref);

List<GeneratedComponent> allGeneratedComponents =
    _globalComponentsCollection.components.values.toList();

final GeneratedComponentsCollection _globalComponentsCollection = GeneratedComponentsCollection();

class GeneratedComponentsCollection {
  final Map<String, GeneratedComponent> components = {};

  void registerGeneratedComponent(String ref, GeneratedComponent component) {
    if (components.containsKey(ref)) {
      throw GeneratedComponentAlreadyDefinedException(ref, components[ref]!);
    } else {
      components[ref] = component;
    }
  }

  GeneratedComponent? getGeneratedComponentByRef(String ref) => components[ref];
}
