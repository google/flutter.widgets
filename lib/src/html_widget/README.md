# html_widget

Limited support for rendering HTML as flutter widgets. currently supports the
following tags:
  - div
  - br
  - table
  - b
  - u
  - a
  - font
  - hr
  - text


## example use

```dart
var source = '''
  <div> This is some html</div>
  <br/>
  <div>
    <a href="/some_link">Click Me</a>
  </div>
''';

var widget = HtmlView(content: source, onTapLink: _callSomeFunction);

```
