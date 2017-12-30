import 'package:html_app/html_app.dart';

const Map<String, dynamic> _parentStyle = const {
  'width': '100%',
  'height': '100%',
  'display': 'flex',
  'flex-direction': 'row',
  'justify-content': 'center',
  'align-items': 'center',
};

VNode content(VNode content) =>
    tag('div', styles: _parentStyle, children: [content]);

VNode toRow(VNode row, {String pad}) {
  row.styles.addAll({
    'display': 'flex',
    'flex-direction': 'row',
    'align-items': 'center',
  });
  if (pad is String) row.styles['padding'] = pad;
  return row;
}

VNode row(List<VNode> children) => toRow(div(children));

VNode box(String title, VNode body, VNode action) {
  final VElement titlebar = row([
    text(title),
    text('', styles: {'flex': 1}),
    action
  ]);
  titlebar.clas += 'edge-box-title';
  return div([titlebar, body], clas: 'edge-box-main');
}
