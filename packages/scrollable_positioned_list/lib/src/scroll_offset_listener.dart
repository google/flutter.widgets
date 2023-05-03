import 'dart:async';

// Provides an affordance for listening to scroll offset changes.
abstract class ScrollOffsetListener {

  // Stream of scroll offset deltas.
  Stream<double> get changes;

  factory ScrollOffsetListener.create() => ScrollOffsetNotifier();
}

class ScrollOffsetNotifier 
    implements ScrollOffsetListener {

  final _streamController = StreamController<double>();

  @override
  Stream<double> get changes => _streamController.stream; 

  StreamController get changeController => _streamController;

  void dispose() {
    _streamController.close();
  }
}