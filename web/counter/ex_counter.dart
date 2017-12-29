import 'package:html_app/html_app.dart';

int count = 0;

void main() {
  final HtmlApp app = start(() => tag(
        'div',
        properties: {'id': 'container'},
        children: [
          tag('div', properties: {
            'text': 'Click the button to icrement me!',
            'id': 'info'
          }),
          tag('div', properties: {'text': count, 'id': 'count'}),
          tag('button', properties: {
            'text': 'Increment',
            'id': 'button'
          }, reactors: {
            'click': (ViewUpdater updater, _) {
              count++;
              updater.updateView();
            },
          }),
        ],
      ));

  app.start();
}
