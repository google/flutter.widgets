import 'dart:async';

import 'scroll_offset_listener.dart';

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
