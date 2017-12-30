import 'dart:html';

import '../virtual/virtual.dart';

class HtmlHelper {
  static void setElementProp(Element element, String name, String value) {
    if (name == 'text') {
      value = value.toString();
      if (element.innerHtml != value) {
        element.innerHtml = value;
      }
      return;
    }

    if (element.getAttribute(name) != value) {
      element.setAttribute(name, value);
    }
  }

  static void setElementStyle(Element element, String name, String value) {
    if (element.getComputedStyle().getPropertyValue(name) != value) {
      element.style.setProperty(name, value);
    }
  }

  static Element createElement(VNode vElement) {
    bool isSvg = false; // TODO

    Element ret;

    if (isSvg) {
      ret = document.createElementNS(
          "http://www.w3.org/2000/svg", vElement.tagName);
    } else {
      ret = document.createElement(vElement.tagName);
    }

    for (String name in vElement.properties.keys) {
      setElementProp(ret, name, vElement.properties[name].toString());
    }

    if (vElement.id != null) ret.id = vElement.id;
    if (vElement.clas != null && vElement.clas.isNotEmpty)
      ret.classes.addAll(vElement.clas.split(' '));

    for (String name in vElement.styles.keys) {
      ret.style.setProperty(name, vElement.styles[name].toString());
    }

    return ret;
  }
}
