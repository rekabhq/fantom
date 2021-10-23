import 'package:fantom/src/exceptions/exceptions.dart';
import 'package:fantom/src/generator/components/component/component.dart';

void registerComponent(String ref, Component component) =>
    _globalComponentsCollection.registerComponent(ref, component);

Component? getComponentByRef(String ref) =>
    _globalComponentsCollection.getComponentByRef(ref);

final ComponentsCollection _globalComponentsCollection = ComponentsCollection();

class ComponentsCollection {
  final Map<String, Component> components = {};

  void registerComponent(String ref, Component component) {
    if (components.containsKey(ref)) {
      throw ComponentAlreadyDefinedException(ref, components[ref]!);
    } else {
      components[ref] = component;
    }
  }

  Component? getComponentByRef(String ref) => components[ref];
}
