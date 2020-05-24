# Menu and dialog GUI for Godot

This project contains custom node types to easily implement a dialogue system with input and choices in Godot 3.2.

Features:

* Rich text support (formatting, colors, effects, etc.)
* Supports keyboard, mouse and multitouch screen
* Blocks the input while dilogue is open, making it "blocking"

__NOTE:__ currently only he text output is implemented

See the included demo for a complete usage example.

## TO DO
- [ ] Use the input to go forward with the text, instead of scrolling automatically till the end
- [ ] Generate a signal when the text is over, or when a special tag (i.e. `[break signalname]`) is reached
- [ ] Create another component with the same behavior but for text input (emits signal when input is sent)
- [ ] Aggregate the two components under an utility one that instantiate and wraps their signals
- [ ] Add component for the list choice
- [ ] Create video showing the usage
- [ ] Publish as addon
