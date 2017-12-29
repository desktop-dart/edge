import 'dart:html';

import '../virtual/virtual.dart';
import 'html_app.dart';

class HtmlHelper {
  static void setElementProp(Element element, String name, value, [oldValue]) {
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

  static Element createElement(VElement vElement) {
    bool isSvg = false; // TODO

    Element ret;

    if (isSvg) {
      ret = document.createElementNS(
          "http://www.w3.org/2000/svg", vElement.tagName);
    } else {
      ret = document.createElement(vElement.tagName);
    }

    for (String name in vElement.properties.keys) {
      setElementProp(ret, name, vElement.properties[name]);
    }

    // TODO update styles

    return ret;
  }
}
