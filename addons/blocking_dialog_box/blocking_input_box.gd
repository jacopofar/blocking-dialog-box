extends CanvasLayer
class_name BlockingInputBox

signal text_entered


# size of the NinePatch frame
export var patch_size: int = 12
# distance to let the text breathe
export var padding: int = 10

# distance from left and right borders
export var hmargin: int = 60

# textbox height
export var height: int = 64

# textbox bottom margin
export var bottom_margin: int = 120

var text_edit: LineEdit
var background: NinePatchRect

# is it visible and catching inputs?
var active: bool = false
# is it waiting for explicit input to continue?
var in_break: bool = false
var break_content: String

func _ready():
	set_process(false)
	set_process_input(false)


func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_ENTER:
				emit_signal("text_entered", text_edit.text)
				hide_box()
				get_tree().set_input_as_handled()	
				return
			if event.scancode == KEY_BACKSPACE:
				text_edit.text = text_edit.text.left(text_edit.text.length() - 1)
			else:
				text_edit.text += char(event.unicode)
			text_edit.caret_position = text_edit.text.length()
		get_tree().set_input_as_handled()		
	# keyboard events are fine, the control already handles them
	# prevent mouse and touch events as far as this is active
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		get_tree().set_input_as_handled()


func show_box():
	var window_size_x = ProjectSettings.get_setting("display/window/size/width")
	var window_size_y = ProjectSettings.get_setting("display/window/size/height")
	background = NinePatchRect.new()
	background.rect_position = Vector2(
		hmargin,
		window_size_y - height - bottom_margin
		)
	background.rect_size = Vector2(
		window_size_x - 2 * hmargin,
		height
		)
	background.texture = load("res://addons/blocking_dialog_box/dialog_frame.png")
	background.patch_margin_top = patch_size
	background.patch_margin_right = patch_size
	background.patch_margin_bottom = patch_size
	background.patch_margin_left = patch_size
	add_child(background)
	
	text_edit = LineEdit.new()
	text_edit.rect_position = Vector2(
		hmargin + padding,
		window_size_y - height - bottom_margin + padding
		)
	text_edit.rect_size = Vector2(
		window_size_x - 2 * (hmargin + padding),
		height - 2 * padding
		)
	var edit_style = StyleBoxFlat.new()
	edit_style.set_bg_color(Color.transparent)
	text_edit.set("custom_styles/normal", edit_style)
	text_edit.set("custom_colors/cursor_color", Color(0,0,0))
	text_edit.set("custom_colors/font_color", Color(0,0,0))
	text_edit.caret_blink = true
	text_edit.expand_to_text_length = false
	


	# this is the code to load a font and use it
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load(
		"res://addons/blocking_dialog_box/NotoSansCJKsc-Regular.otf")
	dynamic_font.size = 18
	text_edit.set("custom_fonts/font", dynamic_font)
	
	add_child(text_edit)
	set_process_input(true)
	set_process(true)
	active = true
	text_edit.grab_focus()

func hide_box():
	background.queue_free()
	text_edit.queue_free()
	active = false
	set_process_input(false)
	set_process(false)

func ask_input():
	# this is ugly, but on mobile there's no keyboard usually :(
	if OS.get_name() == "HTML5":
		# extra ugly!
		# possible alternatives:
		# 1. Create an HTML input element and focus it to trigger the virtual
		#    keyboard to appear
		#    This is tricky because focus can only be given in an "input context"
		# 2. Always show a virtual keyboard
		#    Such a keyboard would probably destroy i18n and accessibility
		# 3. Add button to switch
		#    The user could see some button to invoke the JS window.prompt()
		#    Could be hard to understand
		var detected_mobile = JavaScript.eval(
			"/Mobi|Android/i.test(navigator.userAgent)",
			true
			)
		if detected_mobile:
			var text = JavaScript.eval("prompt('Enter:', '');", true)
			emit_signal("text_entered", text)
			return
	if not active:
		show_box()
		active = true
		text_edit.connect("text_entered", self, "text_entered")
	else:
		print("WARNING: asking for input while input box is already open!")

func text_entered(text: String):
	emit_signal("text_entered", text)
	hide_box()
