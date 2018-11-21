VisibilityDetector
==================

A `VisibilityDetector` widget wraps an existing Flutter widget and fires a
callback when the widget's visibility changes. (It actually reports when the
visibility of the `VisibilityDetector` itself changes, and its visibility is
expected to be identical to that of its child.)

Callbacks are not fired immediately on visibility changes.  Instead, callbacks
are deferred and coalesced such that the callback for each `VisibilityDetector`
will be invoked at most once per `VisibilityDetectorController.updateInterval`
(unless forced by `VisibilityDetectorController.notifyNow()`).  Callbacks for
*all* `VisibilityDetector` widgets are fired together synchronously between
frames.

`VisibilityDetectorController.notifyNow()` may be used to force triggering
pending visibility callbacks; this might be desirable just prior to tearing down
the widget tree (such as when switching views or when exiting the application).

For more details, see the documentation to the `VisibilityDetector`,
`VisibilityInfo`, and `VisibilityDetectorController` classes.


Widget tests
------------

Widget tests that use `VisibilityDetector`s usually should set:

```dart
VisibilityDetectorController.instance.updateInterval = Duration.zero;
```

This will have two effects:

1. Visibility changes will be reported immediately, which can be less surprising
   for automated tests.

2. It avoids the following assertion when tearing down the widget tree:

   > The following assertion was thrown running a test: \
   > A Timer is still pending even after the widget tree was disposed.

   See https://github.com/flutter/flutter/issues/24166 for details.

If setting `updateInterval = Duration.zero` is undesirable, to address each of
the corresponding issues above, tests alternatively can:

1. Wait sufficiently long for callbacks to fire:

   ```dart
   await tester.pump(VisibilityDetectorController.instance.updateInterval);
   ```

2. Avoid the "Timer is still pending..." assertion by explicitly destroying the
   widget tree before the test completes:

   ```dart
   await tester.pumpWidget(Placeholder());
   ```

See `test/widget_test.dart` for examples.
