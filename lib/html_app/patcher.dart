part of jaguar.html.app;

class HtmlRenderer {
  ViewUpdater updateRequester;

  HtmlRenderer([this.updateRequester]);

  Element _createElement(Element parent, final VNode vElement) {
    Element ret = HtmlHelper.createElement(vElement);

    // Attach reactors
    for (String name in vElement.reactors.keys) {
      ret.on[name]
          .listen((event) => vElement.reactors[name](updateRequester, event));
    }

    if (vElement is VElement) {
      for (int i = 0; i < vElement.children.length; i++) {
        ret.append(patch(ret, null, null, vElement.children[i]));
      }
    }

    return ret;
  }

  void _updateElement(Element element, VNode oldVElement, VNode newVElement) {
    // Properties/attributes
    {
      final Map<String, dynamic> oldProps = oldVElement.properties;

      // TODO remove old properties

      // Set new properties
      for (String name in newVElement.properties.keys) {
        final value = newVElement.properties[name];
        if (!oldProps.containsKey(name) || value != oldProps[name]) {
          HtmlHelper.setElementProp(element, name, value.toString());
        }
      }
    }

    // Styles
    {
      final Map<String, dynamic> oldStyles = oldVElement.styles;

      // TODO remove old styles

      // Set new properties
      for (String name in newVElement.styles.keys) {
        final value = newVElement.styles[name];
        if (!oldStyles.containsKey(name) || value != oldStyles[name]) {
          HtmlHelper.setElementStyle(element, name, value.toString());
        }
      }
    }

    // Classes
    {
      // TODO
    }
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

      final VNode oldChild = oldVElement.children[i];
      final String oldKey = oldChild.key;
      if (oldKey != null)
        oldKeyed[oldKey] = new _ElementPair(oldElements[i], oldChild);
    }

    final newKeyed = <String, VNode>{};

    int oldIndex = 0;
    int newIndex = 0;

    while (newIndex < vElement.children.length) {
      final VNode oldChild = oldVElement.children[oldIndex];
      final VNode newChild = vElement.children[newIndex];

      final String oldKey = oldChild.key;
      final String newKey = newChild.key;

      if (newKeyed.containsKey(oldKey)) {
        oldIndex++;
        continue;
      }

      if (null == newKey) {
        if (null == oldKey) {
          patch(element, oldElements[oldIndex], oldChild, newChild);
          newIndex++;
        }
        oldIndex++;
        continue;
      }

      final _ElementPair recyledNode =
          oldKeyed[newKey] ?? new _ElementPair(null, null);

      if (oldKey == newKey) {
        patch(element, recyledNode.element, recyledNode.vElement, newChild);
        oldIndex++;

        newIndex++;
        newKeyed[newKey] = newChild;
        continue;
      }

      if (recyledNode.element != null) {
        patch(
            element,
            element.insertBefore(recyledNode.element, oldElements[oldIndex]),
            recyledNode.vElement,
            newChild);

        newIndex++;
        newKeyed[newKey] = newChild;
        continue;
      }

      patch(element, oldElements[oldIndex], null, newChild);

      newIndex++;
      newKeyed[newKey] = newChild;
      continue;
    }

    // Remove the excess elements in [element]
    while (oldIndex < oldVElement.children.length) {
      final VNode oldChild = oldVElement.children[oldIndex];
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

  void _removeElement(Element parent, Element element, VNode oldVElement) {
    parent.children.remove(element);
  }

  Element patch(Element parent, Element oldElement, VNode oldVElement,
      VNode newVElement) {
    Element newElement;
    if (identical(newVElement, oldVElement)) {
      // Identical. Nothing to patch!
      newElement = oldElement;
    } else if (newVElement is VMountable) {
      newElement =
          newVElement.mountAt(updateRequester, parent, oldElement, oldVElement);
    } else if (oldVElement == null) {
      newElement =
          parent.insertBefore(_createElement(parent, newVElement), oldElement);
    } else if (newVElement.tagName == oldVElement.tagName) {
      newElement = oldElement;
      if (newVElement is VElement) {
        if (oldVElement is VElement) {
          _updateElement(newElement, oldVElement, newVElement);
          _syncElementChildren(newElement, oldVElement, newVElement);
        } else {
          newElement = parent.insertBefore(
              _createElement(parent, newVElement), oldElement);
          _removeElement(parent, oldElement, oldVElement);
        }
      } else {
        _updateElement(newElement, oldVElement, newVElement);
        newElement.children.clear();
      }
    } else {
      newElement =
          parent.insertBefore(_createElement(parent, newVElement), oldElement);
      _removeElement(parent, oldElement, oldVElement);
    }

    return newElement;
  }
}
