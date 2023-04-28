import 'dart:async';

abstract class ScrollOffsetListener {
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