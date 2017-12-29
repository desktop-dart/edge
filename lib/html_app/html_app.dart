library jaguar.html.app;

import 'dart:async';
import 'dart:html';

import '../virtual/virtual.dart';
import 'html_helper.dart';

class _ElementPair {
  Element element;

  VElement vElement;

  _ElementPair(this.element, this.vElement);
}

class HtmlApp implements App {
  Map<String, ComponentCreator> _componentCreators = {};

  Element _createElement(VElement vElement) {
    if (vElement.tagName.startsWith('v@')) {
      if (_componentCreators.containsKey(vElement.tagName)) {
        return null; // TODO
      }
    }

    Element ret = HtmlHelper.createElement(vElement);

    // TODO Lifecycle: publish even that [vElement] is created

    // Reactors
    for (String name in vElement.reactors.keys) {
      ret.on[name].listen((event) => vElement.reactors[name](this, event));
    }

    for (int i = 0; i < vElement.children.length; i++) {
      ret.append(_createElement(vElement.children[i]));
    }

    return ret;
  }

  void _updateElement(Element element, VElement oldNode, VElement node) {
    final Map<String, dynamic> oldProps = oldNode.properties;

    // TODO remove old properties

    // Set new properties
    for (String name in node.properties.keys) {
      final value = node.properties[name];
      if (!oldProps.containsKey(name) || value != oldProps[name]) {
        HtmlHelper.setElementProp(element, name, value, oldProps[name]);
      }
    }

    // TODO Lifecycle: publish that [node] updated
  }

  /// Syncs the children of [element] to the specification of [vElement] by
  /// morphing it from old [oldVElement].
  void _syncElementChildren(
      Element element, VElement oldVElement, VElement vElement) {
    final oldElements = <Element>[];
    final oldKeyed = <String, _ElementPair>{};

    // Find old elements and old keys
    for (int i = 0; i < oldVElement.children.length; i++) {
      oldElements.add(element.children[i]);

      final VElement oldChild = oldVElement.children[i];
      final String oldKey = oldChild.key;
      if (oldKey != null)
        oldKeyed[oldKey] = new _ElementPair(oldElements[i], oldChild);
    }

    final newKeyed = <String, VElement>{};

    int oldIndex = 0;
    int newIndex = 0;

    while (newIndex < vElement.children.length) {
      final VElement oldChild = oldVElement.children[oldIndex];
      final VElement newChild = vElement.children[newIndex];

      final String oldKey = oldChild.key;
      final String newKey = newChild.key;

      if (newKeyed.containsKey(oldKey)) {
        oldIndex++;
        continue;
      }

      if (null == newKey) {
        if (null == oldKey) {
          _patch(element, oldElements[oldIndex], oldChild, newChild);
          newIndex++;
        }
        oldIndex++;
        continue;
      }

      final _ElementPair recyledNode =
          oldKeyed[newKey] ?? new _ElementPair(null, null);

      if (oldKey == newKey) {
        _patch(element, recyledNode.element, recyledNode.vElement, newChild);
        oldIndex++;

        newIndex++;
        newKeyed[newKey] = newChild;
        continue;
      }

      if (recyledNode.element != null) {
        _patch(
            element,
            element.insertBefore(recyledNode.element, oldElements[oldIndex]),
            recyledNode.vElement,
            newChild);

        newIndex++;
        newKeyed[newKey] = newChild;
        continue;
      }

      _patch(element, oldElements[oldIndex], null, newChild);

      newIndex++;
      newKeyed[newKey] = newChild;
      continue;
    }

    // Remove the excess elements in [element]
    while (oldIndex < oldVElement.children.length) {
      final VElement oldChild = oldVElement.children[oldIndex];
      if (null == oldChild.key) {
        _removeElement(element, oldElements[oldIndex], oldChild);
      }
      oldIndex++;
    }

    for (_ElementPair key in oldKeyed.values) {
      if (newKeyed[key.vElement.key] == null) {
        _removeElement(element, key.element, key.vElement);
      }
    }
  }

  void _removeElement(Element parent, Element element, VElement vElement) {
    parent.children.remove(element);
  }

  Element _patch(Element parent, Element oldElement, VElement oldVElement,
      VElement newVElement) {
    Element newElement;
    if (identical(newVElement, oldVElement)) {
      // Identical. Nothing to patch!
      newElement = oldElement;
    } else if (oldVElement == null) {
      newElement = parent.insertBefore(_createElement(newVElement), oldElement);
    } else if (newVElement.tagName == oldVElement.tagName) {
      newElement = oldElement;
      _updateElement(newElement, oldVElement, newVElement);
      _syncElementChildren(newElement, oldVElement, newVElement);
    } else {
      newElement = parent.insertBefore(_createElement(newVElement), oldElement);
      _removeElement(parent, oldElement, oldVElement);
    }

    return newElement;
  }

  Renderer _viewRenderer;

  Element _root;

  // TODO allow both function and component based renderers
  HtmlApp(Renderer viewRenderer, {Element root})
      : _root = root ?? document.body,
        _viewRenderer = viewRenderer {
    updateView();
  }

  Element element;
  VElement _rootVElement;

  @override
  Future updateView() async {
    final VElement oldVElement = _rootVElement;
    _rootVElement = await _viewRenderer();
    element = _patch(_root, element, oldVElement, _rootVElement);
  }
}

HtmlApp start(Renderer viewRenderer, {Element root}) =>
    new HtmlApp(viewRenderer, root: root);

typedef FutureOr<VElement> Renderer();
