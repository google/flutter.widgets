# 0.1.7

* Properly bounds ScrollablePositionedList to fix
  ([issue #23](https://github.com/google/flutter.widgets/issues/23)).

* Allow ScrollablePositionedList alignment outside [0..1] to fix
  ([issue #31](https://github.com/google/flutter.widgets/issues/31)).
  
* Move ScrollablePositionedList example into example subdirectory.
  
# 0.1.6

* Added `ScrollablePositionedList`.
* Fixed an incompatibility in `VisibilityDetector` with Flutter 1.9.1
  ([issue #20](https://github.com/google/flutter.widgets/issues/20)).
* Removed dependency on package:intl.

# 0.1.5

* Clarified authors in pubspec.yaml.

* Fixed lint violations of prefer_collection_literals.

* Adjust the minimum versions of dependencies.

# 0.1.4

* `VisibilityDetector`:

  * Fixed positioning of text selection handles for `EditableText`-based
    widgets (e.g. `TextField`, `CupertinoTextField`) when used within a
    `VisibilityDetector`.

  * Added `VisibilityDetectorController.widgetBoundsFor`.

# 0.1.3

* Compatibility fixes for Flutter 1.3.0.

# 0.1.2

* Added `VisibilityDetectorController.forget`.

# 0.1.1

* Add `LinkedScrollContainer` and `VisibilityDetector` widgets.

# 0.1.0

Initial release featuring:

* `html_widget`: Limited support for rendering HTML as flutter widgets.
  currently supports the following tags:
  `div`, `br`, `table`, `b`, `u`, `a`, `font`, `hr`, `text`

* `tagged_text`: Support for styling text using custom HTML-like tags. This is
  particularly useful for styling text within a translated string.
