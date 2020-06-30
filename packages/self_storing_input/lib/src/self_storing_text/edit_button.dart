import 'dart:math';

import 'package:flutter/material.dart';

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
    RenderBox renderBox = context.findRenderObject();
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
        builder: (context) => Positioned(
              left: getOverlayPosition(
                buttonOffset: offset.dx,
                overlaySize: widget.state.style.overlayWidth,
                buttonSize: renderBox.size.width,
                areaSize: MediaQuery.of(context).size.width,
              ),
              top: getOverlayPosition(
                buttonOffset: offset.dy,
                overlaySize: widget.state.style.overlayHeight,
                buttonSize: renderBox.size.height,
                areaSize: MediaQuery.of(context).size.height,
              ),
              child: Material(
                elevation: widget.state.style.overlayElevation,
                child: OverlayBox(widget.state),
              ),
            ));
  }

  /// Calculates the overlay position for one dimension.
  ///
  /// The preferred position of the overlay is to place
  /// its top-left corner in the center of the corresponding
  /// edit button.
  /// The overlay position will be adjusted, if necessary,
  /// to fit on the screen if possible.
  static double getOverlayPosition({
    double buttonOffset,
    double overlaySize,
    double buttonSize,
    double areaSize,
  }) {
    var buttonCenter = buttonOffset + buttonSize / 2;
    if (buttonCenter + overlaySize <= areaSize) {
      return buttonCenter;
    }
    return max(0, areaSize - overlaySize);
  }
}
