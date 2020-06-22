extends CanvasLayer
class_name BlockingInputBox

signal text_inserted


# size of the NinePatch frame
export var patch_size: int = 12
# distance to let the text breathe
export var padding: int = 6

# distance from left and right borders
export var hmargin: int = 60

# textbox height
export var height: int = 64

# textbox bottom margin
export var bottom_margin: int = 64

var text_edit: TextEdit
var background: NinePatchRect

# is it visible and catching inputs?
var active: bool = false
# is it waiting for explicit input to continue?
var in_break: bool = false
var break_content: String

func _ready():
	set_process(false)
	set_process_input(false)


func show_box():
	var window_size_x = ProjectSettings.get_setting("display/window/size/width")
	var window_size_y = ProjectSettings.get_setting("display/window/size/height")
	background = NinePatchRect.new()
	background.rect_position = Vector2(hmargin, window_size_y - height - bottom_margin)
	background.rect_size = Vector2(window_size_x - 2 * hmargin, height)
	background.texture = load("res://addons/blocking_dialog_box/dialog_frame.png")
	background.patch_margin_top = patch_size
	background.patch_margin_right = patch_size
	background.patch_margin_bottom = patch_size
	background.patch_margin_left = patch_size
	add_child(background)
	
	text_edit = TextEdit.new()
	text_edit.rect_position = Vector2(hmargin + padding, window_size_y - height - bottom_margin + padding)
	text_edit.rect_size = Vector2(window_size_x - 2 * (hmargin + padding), height - 2 * padding)
	text_edit.set("custom_colors/default_color", Color(0,0,0))

	# this is the code to load a font and use it
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://addons/blocking_dialog_box/NotoSansCJKsc-Regular.otf")
	dynamic_font.size = 18
	text_edit.set("custom_fonts/normal_font", dynamic_font)

	add_child(text_edit)
	set_process_input(true)
	set_process(true)
	active = true

func hide_box():
	background.queue_free()
	text_edit.queue_free()
	active = false
	set_process_input(false)
	set_process(false)

func ask_input():
	if not active:
		show_box()
		active = true

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			capture_input()
		else:
			get_tree().set_input_as_handled()	
	# the player can click to proceed, too, to read further
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			capture_input()
		# do not let a rogue release event propagate
		else:
			get_tree().set_input_as_handled()	

# helper to react to the input event, preventing it from propagating
# and closing the input box when done
func capture_input():
	if in_break:
		in_break = false
		get_tree().set_input_as_handled()
		set_process(true)
		emit_signal("break_ended", break_content)
		return
