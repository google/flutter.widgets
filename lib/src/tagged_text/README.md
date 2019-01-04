# tagged_text

Supports styling text using custom HTML tags. This is particularly useful for
styling text within a translated string.

NOTE: HTML is used only because it provides a convenient way to mark up text
that is supported by translators. This widget intentionally does not
provide any additional HTML functionality. See `HtmlWidget` if you want
additional HTML support.

## Usage

The widget takes in a map of text span builders by tag name, and the string to
render.

For example:

```dart
String greeting(String name) => Intl.message(
      'Hello, my name is <name>$name</name>',
      name: 'greeting',
      args: [name],
      desc: '...',
    );

new TaggedText(
  content: greeting('Bob'),
  tagToTextSpanBuilder: {
    'name': (text) => new TextSpan(
        text: text,
        const TextStyle(fontWeight: FontWeight.bold),
  },
  style: Theme.of(context).textTheme.body1,
);
```

Would result in a widget that looks like:

> Hello, my name is **Bob**!

### Clickable spans

`TextSpan` accepts a `GestureRecognizer` in its constructor. You can use this to
link to screens in your string.

For example:

```dart
new TaggedText(
  content: '<campaign-name>Search campaign 1</campaign-name> has 400 clicks.',
  tagToTextSpanBuilder: {
    'campaign-name': (text) => new TextSpan(
        text: text,
        style: const TextStyle(decoration: TextDecoration.underline),
        recognizer: new TapGestureRecognizer()..onTap = () {
          // Go to campaign screen...
        })
  },
  style: Theme.of(context).textTheme.body1,
);
```
