import 'dart:async';

/// Reactor function for an output event
typedef FutureOr OutputReactor<ED>(ViewUpdater updater, ED eventData);

abstract class ViewUpdater {
  void updateView();
}

abstract class VNode {
  String get key;

  String get tagName;

  Map<String, dynamic> get properties;

  Map<String, OutputReactor> get reactors;
}

abstract class VElement implements VNode {
  List<VNode> get children;
}

class VHtmlElementTag implements VElement {
  String key;

  String tagName;

  final Map<String, dynamic> properties;

  final Map<String, OutputReactor> reactors;

  final List<VNode> children;

  VHtmlElementTag(this.tagName,
      {this.key,
      Map<String, dynamic> properties,
      List<VNode> children,
      Map<String, OutputReactor> reactors})
      : properties = properties ?? {},
        children = children ?? [],
        reactors = reactors ?? {};
}

VElement tag(String tagName,
        {String key,
        Map<String, dynamic> properties,
        List<VNode> children,
        Map<String, OutputReactor> reactors}) =>
    new VHtmlElementTag(tagName,
        key: key,
        properties: properties,
        children: children,
        reactors: reactors);

typedef VNode RenderFunc();

abstract class Component {
  VNode render();
}

abstract class RenderedComponent implements ViewUpdater {
  Future updateView();
}
