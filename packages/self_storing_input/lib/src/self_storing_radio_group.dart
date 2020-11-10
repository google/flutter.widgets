import 'package:flutter/material.dart';
import 'package:self_storing_input/src/self_storing_radio_group/custom_radio.dart';
import 'package:self_storing_input/src/self_storing_radio_group/shared_state.dart';

import 'primitives/overlay.dart';
import 'primitives/saver.dart';
import 'primitives/the_progress_indicator.dart';
import 'self_storing_radio_group/self_storing_radio_group_style.dart';

/// A widget to enter and store a boolean value.
class SelfStoringRadioGroup<K> extends StatefulWidget {
  /// [Saver.validate] will not be invoked for [SelfStoringRadioGroup].
  final Saver<K> saver;

  /// Key of the item to be provided to [saver].
  final K itemKey;
  final OverlayController overlayController;
  final SelfStoringRadioGroupStyle style;

  /// Value to use if the loaded value is not in the list of values or
  /// if all values are unchecked.
  final Object? defaultValue;

  /// If true, the radio buttons in the group can be unselected,
  /// returning to the state when user did not enter a value yet.
  final bool isUnselectable;

  /// Map <value, display name>.
  final Map<Object, String> items;

  SelfStoringRadioGroup(
    this.itemKey, {
    Key? key,
    saver,
    overlayController,
    this.style = const SelfStoringRadioGroupStyle(),
    required this.items,
    this.defaultValue,
    this.isUnselectable = false,
  })  : overlayController = overlayController ?? OverlayController(),
        this.saver = saver ?? NoOpSaver<K>(),
        super(key: key);

  @override
  _SelfStoringRadioGroupState createState() => _SelfStoringRadioGroupState();
}

class _SelfStoringRadioGroupState extends State<SelfStoringRadioGroup> {
  bool _isLoading = true;
  SharedState? _state;

  @override
  void initState() {
    _loadValue();
    super.initState();
  }

  @override
  void dispose() {
    _state!.removeListener(_emptySetState);
    widget.overlayController.removeListener(_state!.closeOverlay);
    super.dispose();
  }

  void _emptySetState() => setState(() {});

  Future<void> _loadValue() async {
    Object? storedValue = await widget.saver.load<Object>(widget.itemKey);
    if (!widget.items.containsKey(storedValue))
      storedValue = widget.defaultValue;

    _isLoading = false;
    _state = SharedState(
      widget.defaultValue,
      widget.overlayController,
      widget.saver,
      widget.itemKey,
      widget.style,
      storedValue,
      widget.isUnselectable,
    )..addListener(_emptySetState);
    widget.overlayController.addListener(_state!.closeOverlay);

    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return theProgressIndicator;

    List<Widget> elements = widget.items.keys
        .map((v) => _buildRadioButton(v, widget.items[v] ?? ''))
        .toList(growable: false);
    return Column(
      children: elements,
    );
  }

  Widget _buildRadioButton(Object value, String name) {
    return Row(
      children: [
        CustomRadio(_state, value),
        Flexible(child: Text(name)),
        if (_state!.isSaving as bool && _state!.pendingValue == value)
          theProgressIndicator,
      ],
    );
  }
}
