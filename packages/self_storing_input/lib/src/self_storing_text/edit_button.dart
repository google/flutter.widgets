import 'package:flutter/material.dart';

import '../primitives/overlay_builder.dart';
import 'overlay_box.dart';

/// Button that opens editing area when clicked.
class EditButton extends StatefulWidget {
  final SharedState state;

  const EditButton(this.state);

  @override
  _EditButtonState createState() => _EditButtonState();
}

class _EditButtonState extends State<EditButton> {
  OverlayEntry _overlay;

  @override
  void initState() {
    widget.state.overlayController.addListener(_closeOverlay);
    super.initState();
  }

  @override
  void dispose() {
    widget.state.overlayController.removeListener(_closeOverlay);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        widget.state.overlayController.close();
        _overlay = _buildOverlay(context);
        Overlay.of(context).insert(_overlay);
      },
    );
  }

  void _closeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  OverlayEntry _buildOverlay(BuildContext context) {
    return createOverlayInTheMiddle(
      OverlayBox(widget.state),
      context,
      widget.state.style.overlayStyle,
    );
  }
}
