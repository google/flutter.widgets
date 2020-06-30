# self_storing_input
A set of input widgets that automatically save and load
the entered value to a data store.

## Demo

[https://self_storing_input.codemagic.app](https://self_storing_input.codemagic.app)

## Usage

### Define Saver

Implement a Saver that loads, validates and saves data items by itemKey. 
The itemKey can be of any form. You can make it a resource URL string   
or a tuple <connectionString, table, objectId, column>.

Find example of an in-memory Saver  
[here]('https://github.com/google/flutter.widgets/tree/master/packages/self_storing_input/example/lib/main.dart#L16').

### Define Input

Add self storing input widgets to your screen and parameterize each with the
defined Saver and itemKey. The widgets will take care of loading data, 
validating data, saving data, and handling failure modes like poor internet
connection and data storage failures.

### Close Editing Overlays on Tap

Define an OverlayController in your screen state:

```
OverlayController _controller = OverlayController();
```

Wrap your screen widget body with a GestureDetector to close editing overlays
on tap:

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
