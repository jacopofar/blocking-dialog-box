# Menu and dialog GUI for Godot

This project contains custom node types to easily implement a dialogue system with input and choices in __Godot 3.2__.

It's designed to work with mouse, keyboard and multitouch, and in HTML5 deployments.

Features:

* Rich text support (formatting, colors, effects, etc.) using BBCode
* Display test immediately or writing it at a given speed, mix speeds
* Allows the player to accelerate a dialogue (can be disabled)
* Place breaks and associate signals to them
* Supports keyboard, mouse and multitouch input
* __Blocks__ the input while dilogues is open
* Decent unicode support (it includes Noto Sans font)

![how input is given](screenshots/input.png)
![how text is displayed](screenshots/text.png)
![how a choice is made](screenshots/choice.png)


## How to use

You can see the included demo for a complete usage example, but here's a textual documentation

### Step 0 - install the plugin

This repository works as a Godot project that you can use to run the demo.
To only use the plugin in your game you need only the `addons/blocking_dialog_box` folder. Copy it inside your `addons` folder then enable the plugin under `Project -> project settings -> addons`

### Step 1 - insert the nodes in your project

Activating the plugin will add 3 new node types:

* BlockingDialogBox
* BlockingInputBox
* BlockingListSelection

You need to insert these nodes in this order in your main scene.

Notice that they are independent and you can import only what you need, but you should keep the relative order for them to overlap correctly.

### Step 2 - use the nodes as needed

To use the dialogue nodes you need to retrieve a reference and call their functions.

For example to display text:

```GDScript
# this assumes your main scene is called Main
var bdb: BlockingDialogBox = get_node("/root/Main/BlockingDialogBox")
bdb.append_text("Hello world! (slow)\n", 90)
bdb.append_text("Immediate, and supports [shake]effects[/shake]\n", 0)
```

the dialog box will automatically open, intercept the input to scroll and close itself when done.

To detect breaks do this:

```GDScript
func your_function():
  bdb.append_text("wait for input and rotate[break clockwise]\n", 10)
	var direction: String = yield(bdb, "break_ended")
	rotate_me(direction)
	bdb.append_text("wait for input and rotate back[break counterclockwise]\n", 10)
	direction = yield(bdb, "break_ended")
	rotate_me(direction)

func rotate_me(direction: String):
	if direction == "clockwise":
		$AnimationPlayer.play("rotate")
	if direction == "counterclockwise":
		$AnimationPlayer.play_backwards("rotate")
```

the `[break X]` tag will wait for the player input and then produce `break_reached` and `break_ended` signals containing the `X` parameter string.
The player can accelerate a dialogue by pressing the input button (enter, or the mouse, or the multi-touch) using `[set_skip 0]` will make a dialogue unskippable to the player (use it with caution!) while `[set_skip 300]` will set back the default time skip 300 milliseconds upon input.

Here `yield` is used to make the code more readable, but you can also manually connect and disconnect:

```GDScript
  bdb.append_text("wait for input and rotate[break clockwise]\n", 10)
  bdb.connect("break_ended", self, "rotate_me")

def rotate_me(direction: String):
  bdb.disconnect("break_ended", self, "rotate_me")
  # do something with the direction
```
this is less concise and prone to error if you forget to disconnect but allows you to trigger multiple events and manage signals independently.
__Important note__: you cannot always use `yield` like this, for example it doesn't work on the selection element. In that case use signals explicitly. You can find examples in the included demo.
Hopefully in Godot 4 there will be `await` with a nicer usage.

The input function is similar:

```GDScript
var bib: BlockingInputBox = get_node("/root/Main/BlockingInputBox")
bib.ask_input()
var name: String = yield(bib, "text_entered")
# here do something with the name
```

same to select an element from a list:

```GDScript
var bls: BlockingListSelection = get_node("/root/Main/BlockingListSelection")
bls.ask_value(['green', 'blue', 'arrakis'])
bls.connect("choice_made", self, "when_item_selected")
```

## Input blocking

These three elements are designed to prevent inputs, so that for example when you choose an option in a list the UI actions don't move the character in background.

In general input is blocked if and only if the elements are displayed, and all the elements define a logic to close themselves and stop grabbing the input.

### With the keyboard
Using the keyboard the `ENTER` key goes forward in a dialogue and stops breaks.
The input box decodes the character and allows to cancel the latest one using `backspace`.
If IME is active (you can activate it globally using `OS.set_ime_active(true)`) the input element supports it.
When you are on HTML5 and mobile (mobile detection is based on agent string, couldn't find a nicer way), `window.prompt` is used instead to overcome the lack of a keyboard.

Element selection can be done with arrow keys, you can scroll faster using page up/down and select with `enter`.

### With the mouse

Left clicking advances in dialogue, scrolling the wheel moves the se3lection in the element list and clicking an element selects it.
Text input still requires a keyboard.

### Multitouch
Works like a mouse, except that you can swipe vertically in the element list to scroll and click on an element directly or clicking outside the box will select the currently selected element.

## License and contributing
This project is MIT licensed, you can use it in your own games and edit it as you please.
Contributions and feedback are welcome!
