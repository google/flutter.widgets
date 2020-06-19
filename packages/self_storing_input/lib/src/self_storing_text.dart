import 'package:flutter/material.dart';

import 'primitives/saver.dart';
import 'primitives/the_progress_indicator.dart';
import 'self_storing_text/overlay_box.dart';
import 'self_storing_text/overlay_controller.dart';
import 'self_storing_text/self_storing_text_style.dart';

/// A widget to enter and store single or multiline text.
class SelfStoringText extends StatefulWidget {
  final Saver saver;
  final Object address;
  final String emptyText;
  final OverlayController overlayController;
  final SelfStoringTextStyle style;

  SelfStoringText(
    this.address, {
    Key key,
    this.saver = const NoOpSaver(),
    this.emptyText = '--',
    overlayController,
    this.style = const SelfStoringTextStyle(),
  })  : overlayController = overlayController ?? OverlayController(),
        super(key: key);

  @override
  _SelfStoringTextState createState() => _SelfStoringTextState();
}

class _SelfStoringTextState<D> extends State<SelfStoringText> {
  EditingSession _editingSession;
  bool _isLoading = true;
  OverlayEntry _overlay;

  @override
  void initState() {
    _loadValue();
    super.initState();
  }

  void _closeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  Future _loadValue() async {
    var storedValue = await widget.saver.load<String>(widget.address);
    _editingSession = EditingSession(
      storedValue,
      widget.overlayController,
      widget.saver,
      widget.address,
      widget.style,
    )..addListener(() => setState(() {}));
    _editingSession.overlayController.addListener(_closeOverlay);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return TheProgressIndicator();
    }

    var text = _editingSession.storedValue;
    if (text == null || text.isEmpty) text = widget.emptyText;

    return Row(
      children: [
        Text(text),
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            _editingSession.overlayController.close();
            _overlay = _buildOverlay(context);
            Overlay.of(context).insert(_overlay);
          },
        ),
      ],
    );
  }

  OverlayEntry _buildOverlay(BuildContext context) {
    RenderBox renderBox = context.findRenderObject();
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
        builder: (context) => Positioned(
              left: offset.dx + widget.style.offsetLeft,
              top: offset.dy + widget.style.offsetTop,
              child: Material(
                elevation: widget.style.overlayElevation,
                child: OverlayBox(_editingSession),
              ),
            ));
  }
}
