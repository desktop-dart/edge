import 'dart:async';
import 'dart:html';

import 'package:html_app/virtual/virtual.dart';
import 'package:html_app/html_app/html_app.dart';

class Task {
  String name;

  bool finished;
}

class TaskComponent implements Component {
  String key;

  Stream onUpdate;

  Task task;

  TaskComponent(this.task);

  VElement render() => vel(
    'div',
    key: key,
    children: [
      vel(
          'div',
          properties: {
            'text': task.name,
          },
          reactors: {
            'click': (_, _1) => print('Clicked!'),
          }
      )
    ],
  );
}

DateTime time = new DateTime.now();
int count = 0;

void main() {
  final App app = start(() => vel(
    'div',
    children: [
      vel(
          'div',
          properties: {
            'text': time,
          },
      ),
      vel(
          'div',
          properties: {
            'text': count,
          }
      ),
      vel(
          'button',
          properties: {
            'text': 'Increment',
          },
          reactors: {
            'click': (App updater, _) {
              count++;
              updater.updateView();
            },
          }
      )
    ],
  ));

  /* TODO
  new Timer.periodic(new Duration(seconds: 5), (_) {
    time = new DateTime.now();
    app.updateView();
  });
  */
}
