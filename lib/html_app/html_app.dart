library jaguar.html.app;

import 'dart:html';

import '../virtual/virtual.dart';
import 'html_helper.dart';

part 'patcher.dart';

class HtmlApp implements ViewUpdater {
  RenderFunc _viewRenderer;

  Element _root;

  // TODO allow both function and component based renderers
  HtmlApp(RenderFunc viewRenderer, {Element root})
      : _root = root ?? document.body,
        _viewRenderer = viewRenderer {
    _patcher = new HtmlRenderer(this);
  }

  HtmlRenderer _patcher;

  Element _element;
  VNode _rootVElement;

  @override
  void updateApp() {
    final VNode oldVElement = _rootVElement;
    _rootVElement = _viewRenderer();
    _element = _patcher.patch(_root, _element, oldVElement, _rootVElement);
  }

  void updateComponent() => updateApp();

  void updateParent() => updateApp();

  void start() => updateApp();
}

HtmlApp start(RenderFunc viewRenderer, {Element root}) =>
    new HtmlApp(viewRenderer, root: root);

/// A pair of [Element] and its backing [VElement]
class _ElementPair {
  Element element;

  VNode vElement;

  _ElementPair(this.element, this.vElement);
}

class VMountable implements VNode, ViewUpdater {
  HtmlRenderer _renderer;

  final Component component;

  VMountable(this.component) {
    _renderer = new HtmlRenderer(this);
    _rootVElement = component.render();
  }

  String get id => _rootVElement.id;

  set id(String v) => _rootVElement.id = id;

  String get clas => _rootVElement.clas;

  set clas(String v) => _rootVElement.clas = clas;

  String get key => _rootVElement.key;

  String get tagName => _rootVElement.tagName;

  Map<String, dynamic> get properties => _rootVElement.properties;

  Map<String, dynamic> get styles => _rootVElement.styles;

  Map<String, OutputReactor> get reactors => _rootVElement.reactors;

  Element _root;

  Element _element;

  VElement _rootVElement;

  ViewUpdater _parentComp;

  Element mountAt(
      ViewUpdater app, Element parent, Element oldElement, VNode oldVElement) {
    _parentComp = app;
    _root = parent;
    _rootVElement = component.render();
    _element = _renderer.patch(_root, oldElement, oldVElement, _rootVElement);
    return _element;
  }

  @override
  void updateApp() => _parentComp?.updateParent();

  void updateComponent() {
    if (_root == null) {
      // TODO throw?
      return;
    }

    final VNode oldVElement = _rootVElement;
    _rootVElement = component.render();
    _element = _renderer.patch(_root, _element, oldVElement, _rootVElement);
  }

  void updateParent() => _parentComp?.updateComponent();
}

VMountable mount(Component component) => new VMountable(component);
