import 'dart:async';

/// Reactor function for an output event
typedef FutureOr OutputReactor<ED>(App updater, ED eventData);

abstract class App {
  Future updateView();
}

abstract class VElement {
  String tagName;

  String key;

  Map<String, dynamic> get properties;

  List<VElement> get children;

  Map<String, OutputReactor> get reactors;
}

class VElementImpl implements VElement {
  String tagName;

  String key;

  final Map<String, dynamic> properties;

  final List<VElement> children;

  final Map<String, OutputReactor> reactors;

  VElementImpl(this.tagName,
      {this.key,
      Map<String, dynamic> properties,
      List<VElement> children,
      Map<String, OutputReactor> reactors})
      : properties = properties ?? {},
        children = children ?? [],
        reactors = reactors ?? {};
}

VElement vel(String tagName,
        {String key,
        Map<String, dynamic> properties,
        List<VElement> children,
        Map<String, OutputReactor> reactors}) =>
    new VElementImpl(tagName,
        key: key,
        properties: properties,
        children: children,
        reactors: reactors);

abstract class Component {
  Stream get onUpdate;

  VElement render();
}

class ComponentCreator {

}
