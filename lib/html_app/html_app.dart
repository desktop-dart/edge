library jaguar.html.app;

import 'dart:async';
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
  void updateView() {
    final VNode oldVElement = _rootVElement;
    _rootVElement = _viewRenderer();
    _element = _patcher.patch(_root, _element, oldVElement, _rootVElement);
  }

  void start() => updateView();
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
  final HtmlRenderer renderer;

  final Component component;

  VMountable(this.component, this.renderer) {
    renderer.updateRequester = this;
    _rootVElement = component.render();
  }

  String get key => _rootVElement.key;

  String get tagName => _rootVElement.tagName;

  Map<String, dynamic> get properties => _rootVElement.properties;

  Map<String, OutputReactor> get reactors => _rootVElement.reactors;

  Element _root;

  Element _element;

  VElement _rootVElement;

  Element mountAt(Element parent, Element oldElement, VNode oldVElement) {
    _root = parent;
    _rootVElement = component.render();
    _element = renderer.patch(_root, oldElement, oldVElement, _rootVElement);
    return _element;
  }

  @override
  void updateView() {
    if(_root == null) {
      // TODO throw?
      return;
    }

    final VNode oldVElement = _rootVElement;
    _rootVElement = component.render();
    _element = renderer.patch(_root, _element, oldVElement, _rootVElement);
  }
}

VMountable mount(Component component) =>
    new VMountable(component, new HtmlRenderer());