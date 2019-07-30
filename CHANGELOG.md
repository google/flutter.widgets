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
