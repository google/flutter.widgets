import 'package:flutter/material.dart';

import '../primitives/operation_result.dart';
import '../primitives/saver.dart';
import '../primitives/the_progress_indicator.dart';
import 'overlay_controller.dart';
import 'self_storing_text_style.dart';

/// State, that needs to be shared between widgets after user clicks 'Edit'.
class EditingSession with ChangeNotifier {
  String _storedValue;
  final OverlayController overlayController;
  final Saver saver;
  final Object address;
  final SelfStoringTextStyle style;

  String get storedValue => _storedValue;
  set storedValue(String value) {
    _storedValue = value;
    notifyListeners();
  }

  EditingSession(
    storedValue,
    this.overlayController,
    this.saver,
    this.address,
    this.style,
  ) : _storedValue = storedValue;
}

/// The panel that pops up, when user clicks 'Edit'.
class OverlayBox extends StatefulWidget {
  final EditingSession session;

  const OverlayBox(
    this.session,
  );

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
    _textController.text = widget.session.storedValue;
    _textController.addListener(_onTextChange);
    super.initState();
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
    _validationError = widget.session.saver
        .validate<String>(widget.session.address, _textController.text)
        .error;
    setState(() {});
  }

  /// This method is invoked when user clicked 'Save'.
  Future<OperationResult> _saveEnteredValue() async {
    // We do not differentiate null and empty value, because TextEditor
    // does not.
    // If original value was null, user clicked 'Edit' and then,
    // without changing value, clicked 'Save', we do not want empty string
    // to be stored.
    if ((_textController.text ?? '') == (widget.session.storedValue ?? '')) {
      return OperationResult.success();
    }

    var operationResult = await widget.session.saver
        .save(widget.session.address, _textController.text);

    if (operationResult.isSuccess) {
      widget.session.storedValue = _textController.text;
    }

    return operationResult;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.session.style.overlayWidth,
        height: widget.session.style.overlayHeight,
        margin: EdgeInsets.symmetric(
            horizontal: widget.session.style.overlayMargin),
        child: _isSaving ? TheProgressIndicator() : buildContent(context));
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
              maxLines: widget.session.style.maxLines,
              keyboardType: widget.session.style.keyboardType,
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
        widget.session.overlayController.close();
        _textController.text = widget.session.storedValue ?? '';
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
                widget.session.overlayController.close();
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
      width: widget.session.style.overlayWidth -
          widget.session.style.overlayMargin * 2 -
          Theme.of(context).buttonTheme.minWidth * 2,
      child: SingleChildScrollView(
        child: Text(text),
      ),
    );
  }
}
