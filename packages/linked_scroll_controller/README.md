# linked_scroll_controller

This package provides a way to set up a set of scrollable widgets whose
scrolling is synchronized. The set can be stable across the lifetime of the
containing screen, or can change dynamically (for example, a vertically
scrolling `ListView.builder()` whose items are Scrollables that scroll
horizontally in unison).

**If you add controllers dynamically, the corresponding scrollables must be
given unique keys to avoid the scroll offset going out of sync.**

# Example usage

The code below sets up two side-by-side `ListView`s that scroll in unison.

```dart
class LinkedScrollables extends StatefulWidget {
  @override
  _LinkedScrollablesState createState() => _LinkedScrollablesState();
}

class _LinkedScrollablesState extends State<LinkedScrollables> {
  LinkedScrollControllerGroup _controllers;
  ScrollController _letters;
  ScrollController _numbers;

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _letters = _controllers.addAndGet();
    _numbers = _controllers.addAndGet();
  }

  @override
  void dispose() {
    _letters.dispose();
    _numbers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              controller: _letters,
              children: <Widget>[
                _Tile('Hello A'),
                _Tile('Hello B'),
                _Tile('Hello C'),
                _Tile('Hello D'),
                _Tile('Hello E'),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: _numbers,
              children: <Widget>[
                _Tile('Hello 1'),
                _Tile('Hello 2'),
                _Tile('Hello 3'),
                _Tile('Hello 4'),
                _Tile('Hello 5'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String caption;

  _Tile(this.caption);

  @override
  Widget build(_) => Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        height: 250.0,
        child: Center(child: Text(caption)),
      );
}

```
