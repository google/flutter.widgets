import 'dart:async';

/// Provides an affordance for listening to scroll offset changes.
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

class ScrollOffsetNotifier implements ScrollOffsetListener {
  final bool recordProgrammaticScrolls;

  ScrollOffsetNotifier({this.recordProgrammaticScrolls = true});

  final _streamController = StreamController<double>();

  @override
  Stream<double> get changes => _streamController.stream;

  StreamController get changeController => _streamController;

  void dispose() {
    _streamController.close();
  }
}
