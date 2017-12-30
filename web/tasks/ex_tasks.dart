import 'package:html_app/html_app.dart';
import '../comps/content.dart';

class Task {
  String name;

  bool finished;

  Task(this.name, this.finished);
}

final List<Task> tasks = [
  new Task('Laundry', false),
  new Task('Benchmark', false)
];

class TaskComponent extends Component {
  Task task;

  TaskComponent(this.task);

  VNode render() => toRow(tag(
        'div',
        styles: {'margin': '10px'},
        children: [
          text(task.name, styles: {'width': '200px'}),
          text('&#128465;', reactors: {
            'click': (updater, _1) {
              tasks.remove(task);
              updater.updateParent();
            },
          }),
        ],
      ));
}

class TaskList extends Component {
  final List<Task> task;

  TaskList(this.task);

  VNode render() => box(
      'Task list',
      div(task.map((t) => mount(new TaskComponent(t))).toList()),
      text('+', reactors: {
        'click': (upd, _) {
          // TODO
        }
      }));
}

void main() {
  final HtmlApp app = start(
    () => content(mount(new TaskList(tasks))),
  );

  app.start();
}
