import 'dart:async';
import 'dart:html';

import 'package:html_app/virtual/virtual.dart';
import 'package:html_app/html_app/html_app.dart';

class Task {
  String name;

  bool finished;

  Task(this.name, this.finished);
}

class TaskComponent implements Component {
  String key;

  Task task;

  int localCount = 0;

  TaskComponent(this.task);

  VNode render() => tag(
        'div',
        key: key,
        children: [
          tag('div', properties: {
            'text': task.name,
          }, reactors: {
            'click': (updater, _1) {
              count++;
              localCount++;
              updater.updateView();
            },
          }),
          tag('div', properties: {
            'text': localCount,
          })
        ],
      );
}

DateTime time = new DateTime.now();
int count = 0;

TaskComponent task = new TaskComponent(new Task('Laundry', false));

void main() {
  final HtmlApp app = start(() => tag(
        'div',
        children: [
          tag(
            'div',
            properties: {
              'text': time,
            },
          ),
          tag('div', properties: {
            'text': count,
          }),
          tag('button', properties: {
            'text': 'Increment',
          }, reactors: {
            'click': (ViewUpdater updater, _) {
              count++;
              updater.updateView();
            },
          }),
          mount(task),
        ],
      ));

  app.start();

  /* TODO
  new Timer.periodic(new Duration(seconds: 5), (_) {
    time = new DateTime.now();
    app.updateView();
  });
  */
}
