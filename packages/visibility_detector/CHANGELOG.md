# 0.2.0

* Added `SliverVisibilityDetector` to report visibility of `RenderSliver`-based
  widgets.  Fixes [issue #174](https://github.com/google/flutter.widgets/issues/174).

# 0.2.0-nullsafety.1

* Revert change to add `VisibilityDetectorController.scheduleNotification`,
  which introduced unexpected memory usage.

# 0.2.0-nullsafety.0

* Update to null safety.

* Try to fix the link to the example on pub.dev.

* Revert tests to again use `RenderView` instead of `TestWindow`.

* Add `VisibilityDetectorController.scheduleNotification` to force firing a
  visibility callback.

# 0.1.5

* Compatibility fixes to `demo.dart` for Flutter 1.13.8.

* Moved `demo.dart` to an `examples/` directory, renamed it, and added
  instructions to `README.md`.

* Adjusted tests to use `TestWindow` instead of `RenderView`.

* Added a "Known limitations" section to `README.md`.

# 0.1.4

* Style and comment adjustments.

* Fix a potential infinite loop in the demo app and add tests for it.

# 0.1.3

* Fixed positioning of text selection handles for `EditableText`-based
  widgets (e.g. `TextField`, `CupertinoTextField`) when used within a
  `VisibilityDetector`.

* Added `VisibilityDetectorController.widgetBoundsFor`.

# 0.1.2

* Compatibility fixes for Flutter 1.3.0.

# 0.1.1

* Added `VisibilityDetectorController.forget`.
