# self_storing_input
A set of input widgets that automatically save and load
the entered value to a data store.

## Demo

[https://self_storing_input.codemagic.app](https://self_storing_input.codemagic.app)

## Usage

### Define Saver

Implement Saver that loads, validates and saves data items by address. Address
can be of any form. You can make it a string that contains resource URL 
or you can make it a structure that contains connection string, table,
object id and column name.

### Define Input

Put self storing input widgets to your screen and parameterize each with the
defined Saver and address. The widgets will take care of loading data, 
validating data, saving data, and handling failure modes like poor internet
connection and data storage failures.

### Close Editing Overlays on Tap

Define OverlayController in your screen state:

```
OverlayController _controller = OverlayController();
```

Wrap your screen widget body with GestureDetector to close editing overlays on tap:

```
GestureDetector(
  onTap: () async {
    _controller.closeOverlay();
  },
  child: Scaffold(
    body: ...
```

Pass `_controller` to each self storing widget:

```
SelfStoringText(
  overlayController: _controller,
  ...
```
