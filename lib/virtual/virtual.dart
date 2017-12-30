import 'dart:async';

/// Reactor function for an output event
typedef FutureOr OutputReactor<ED>(ViewUpdater updater, ED eventData);

abstract class ViewUpdater {
  void updateApp();

  void updateComponent();

  void updateParent();
}

abstract class VNode {
  String get key;

  String get tagName;

  String id;

  String clas;

  Map<String, dynamic> get properties;

  Map<String, dynamic> get styles;

  Map<String, OutputReactor> get reactors;
}

abstract class VElement implements VNode {
  List<VNode> get children;
}

class VHtmlNode implements VNode {
  String key;

  String tagName;

  String id;

  String clas;

  final Map<String, dynamic> properties;

  final Map<String, dynamic> styles;

  final Map<String, OutputReactor> reactors;

  VHtmlNode(this.tagName,
      {this.key,
      this.id,
      clas,
      Map<String, dynamic> properties,
      Map<String, dynamic> styles,
      Map<String, OutputReactor> reactors})
      : clas = clas ?? '',
        properties = properties ?? {},
        reactors = reactors ?? {},
        styles = styles ?? {};
}

class VHtmlElement implements VElement {
  String key;

  String tagName;

  String id;

  String clas;

  final Map<String, dynamic> properties;

  final Map<String, dynamic> styles;

  final Map<String, OutputReactor> reactors;

  final List<VNode> children;

  VHtmlElement(this.tagName,
      {this.key,
      this.id,
      String clas,
      Map<String, dynamic> properties,
      Map<String, dynamic> styles,
      List<VNode> children,
      Map<String, OutputReactor> reactors})
      : clas = clas ?? '',
        properties = properties ?? {},
        children = children ?? [],
        reactors = reactors ?? {},
        styles = styles ?? {};
}

VElement tag(String tagName,
        {String key,
        String id,
        String clas,
        Map<String, dynamic> properties,
        Map<String, dynamic> styles,
        List<VNode> children,
        Map<String, OutputReactor> reactors}) =>
    new VHtmlElement(tagName,
        key: key,
        id: id,
        clas: clas,
        properties: properties,
        styles: styles,
        children: children,
        reactors: reactors);

typedef VNode RenderFunc();

abstract class Component {
  VNode render();
}

VNode text(content,
        {String key,
        String id,
        String clas,
        Map<String, dynamic> properties: const {},
        Map<String, dynamic> styles,
        Map<String, OutputReactor> reactors}) =>
    new VHtmlNode('span',
        key: key,
        id: id,
        clas: clas,
        properties: {'text': content}..addAll(properties),
        styles: styles,
        reactors: reactors);

VNode div(List<VNode> children,
        {String key,
        String id,
        String clas,
        Map<String, dynamic> properties,
        Map<String, dynamic> styles,
        Map<String, OutputReactor> reactors}) =>
    new VHtmlElement('div',
        key: key,
        id: id,
        clas: clas,
        properties: properties,
        styles: styles,
        children: children,
        reactors: reactors);

String classList(List<String> classes) => classes.join(' ');

String classes(String class1, String class2,
    [String class3, String class4, String class5]) {
  final sb = new StringBuffer();
  sb.write('$class1 $class2');

  if (class3 = null) return sb.toString();
  sb.write(' $class3');

  if (class4 != null) return sb.toString();
  sb.write(' $class4');

  if (class5 != null) return sb.toString();
  sb.write(' $class5');

  return sb.toString();
}
