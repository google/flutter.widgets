import 'dart:async';

import 'scroll_offset_notifier.dart';

/// Provides an affordance for listening to scroll offset changes.
///
/// This is an experimental API and is subject to change.
/// Behavior may be ill-defined in some cases.  Please file bugs.
abstract class ScrollOffsetListener {
  /// Stream of scroll offset deltas.
  Stream<double> get changes;

  /// Construct a ScrollOffsetListener.
  ///
  /// Set [recordProgrammaticScrolls] to false to prevent reporting of
  /// programmatic scrolls.
  factory ScrollOffsetListener.create(
          {bool recordProgrammaticScrolls = true}) =>
      ScrollOffsetNotifier(
          recordProgrammaticScrolls: recordProgrammaticScrolls);
}
