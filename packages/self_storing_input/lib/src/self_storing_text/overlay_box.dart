import 'package:flutter/material.dart';

import '../primitives/operation_result.dart';
import '../primitives/overlay.dart';
import '../primitives/saver.dart';
import '../primitives/the_progress_indicator.dart';
import 'self_storing_text_style.dart';

/// State that needs to be shared between [OverlayBox] and its
/// parent.
class SharedState with ChangeNotifier {
  String _storedValue;
  final OverlayController overlayController;
  final Saver saver;
  final Object itemKey;
  final SelfStoringTextStyle style;

  String get storedValue => _storedValue;
  set storedValue(String value) {
    if (value != _storedValue) {
      _storedValue = value;
      notifyListeners();
    }
  }

  SharedState({
    storedValue,
    this.overlayController,
    this.saver,
    this.itemKey,
    this.style,
  }) : _storedValue = storedValue;
}

/// The panel that pops up, when user clicks 'Edit'.
class OverlayBox extends StatefulWidget {
  final SharedState sharedState;

  const OverlayBox(this.sharedState);

  @override
  _OverlayBoxState createState() => _OverlayBoxState();
}

class _OverlayBoxState extends State<OverlayBox> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode()..requestFocus();
  bool _isSaving = false;
  String _validationError;
  String _savingError;

  @override
  void initState() {
    _textController.text = widget.sharedState.storedValue;
    _textController.addListener(_onTextChange);
    super.initState();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChange);
    super.dispose();
  }

  @override
  void setState(fn) {
    // This check takes care of "setState() called after dispose()" exception.
    // See "https://github.com/Norbert515/flutter_villains/issues/8".
    if (mounted) {
      super.setState(fn);
    }
  }

  /// This method is invoked when user types.
  void _onTextChange() {
    _savingError = null;
    _validationError = widget.sharedState.saver
        .validate<String>(widget.sharedState.itemKey, _textController.text)
        .error;
    setState(() {});
  }

  /// This method is invoked when user clicked 'Save'.
  Future<OperationResult> _saveEnteredValue() async {
    var value = _textController.text;
    // We cannot differentiate empty string and null,
    // so we always save null for consistency.
    if (value == '') value = null;

    if (value == widget.sharedState.storedValue) {
      return OperationResult.success();
    }

    var operationResult =
        await widget.sharedState.saver.save(widget.sharedState.itemKey, value);

    if (operationResult.isSuccess) {
      widget.sharedState.storedValue = value;
    }

    return operationResult;
  }

  @override
  Widget build(BuildContext context) {
    return _isSaving ? theProgressIndicator : buildContent(context);
  }

  Widget buildContent(BuildContext context) {
    var error = _validationError ?? _savingError;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: _textController,
              focusNode: _focusNode,
              maxLines: widget.sharedState.style.maxLines,
              keyboardType: widget.sharedState.style.keyboardType,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _textController.text = '';
                  },
                ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            _buildOkButton(),
            _buildCancelButton(),
            if (error != null) _buildErrorWidget(error, context),
          ],
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return FlatButton(
      // Button Cancel
      onPressed: () {
        widget.sharedState.overlayController.close();
        _textController.text = widget.sharedState.storedValue ?? '';
      },
      child: Icon(Icons.close),
    );
  }

  Widget _buildOkButton() {
    return FlatButton(
      // Button OK
      onPressed: _validationError != null
          ? null
          : () async {
              _savingError = null;
              _isSaving = true;
              setState(() {});
              var savingResult = await _saveEnteredValue();
              _savingError = savingResult.error;
              if (savingResult.isSuccess) {
                widget.sharedState.overlayController.close();
              }
              _isSaving = false;
              setState(() => {});
            },
      child: Icon(Icons.check),
    );
  }

  Widget _buildErrorWidget(String text, BuildContext context) {
    return SizedBox(
      height: Theme.of(context).buttonTheme.height,
      width: widget.sharedState.style.overlayStyle.width -
          widget.sharedState.style.overlayStyle.margin * 2 -
          Theme.of(context).buttonTheme.minWidth * 2,
      child: SingleChildScrollView(
        child: Text(text),
      ),
    );
  }
}
