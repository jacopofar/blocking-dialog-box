extends CanvasLayer
class_name BlockingDialogBox

signal break_reached
signal break_ended
signal box_hidden


# size of the NinePatch frame
export var patch_size: int = 12
# distance to let the text breathe
export var padding: int = 6
# textbox height
export var height: int = 128

# elements to display, either single characters or BBCode tags
var elements: PoolStringArray = []
# time in ms to wait each element
var element_times: PoolIntArray = []
# time since the last element was added to the label
var elapsed: int = 0
# extra time added by the player by pressing the input button
# used to accelerate the dialogue
var skipped_time: int = 0
# how much the time will be accelerated for a single pressure of the input button
var skip_interval: int = 300

var label: RichTextLabel
var background: NinePatchRect

# is it visible and catching inputs?
var active: bool = false
# is it waiting for explicit input to continue?
var in_break: bool = false
var break_content: String

func _ready():
	set_process(false)
	set_process_input(false)



func _process(delta):
	# sum the real time that passed and the time the user skipped by pressing input
	elapsed += delta * 1000 + skipped_time
	skipped_time = 0
	while true:
		if elements.size() == 0:
			set_process(false)
			break
		if elapsed > element_times[0]:
			if elements[0].left(6) == "[break":
				in_break = true
				break_content = elements[0].right(7)
				break_content = break_content.left(break_content.length() - 1)
				emit_signal("break_reached", break_content)
				set_process(false)
				element_times.remove(0)
				elements.remove(0)
				break

			if elements[0].left(9) == "[set_skip":
				var skip_content = elements[0].right(9)
				skip_content = skip_content.left(skip_content.length() - 1)
				skip_interval = int(skip_content)
				element_times.remove(0)
				elements.remove(0)
				break
			# carry the remaining time for the next element
			elapsed -= element_times[0]
			label.set_bbcode(label.get_bbcode() + elements[0])
			element_times.remove(0)
			elements.remove(0)
		else:
			break


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


func show_box():
	var window_size_x = ProjectSettings.get_setting("display/window/size/width")
	var window_size_y = ProjectSettings.get_setting("display/window/size/height")
	background = NinePatchRect.new()
	background.rect_position = Vector2(padding, window_size_y - height - padding)
	background.rect_size = Vector2(window_size_x - 2 * padding, height)
	background.texture = load("res://addons/blocking_dialog_box/dialog_frame.png")
	background.patch_margin_top = patch_size
	background.patch_margin_right = patch_size
	background.patch_margin_bottom = patch_size
	background.patch_margin_left = patch_size
	add_child(background)

	label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.scroll_following = true
	label.rect_position = Vector2(
		padding * 2 + patch_size,
		window_size_y - height + padding
		)
	label.rect_size = Vector2(
		window_size_x - patch_size - padding * 2,
		height - patch_size  - padding * 2
		)
	label.set("custom_colors/default_color", Color(0,0,0))

	# this is the code to load a font and use it
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load(
		"res://addons/blocking_dialog_box/NotoSansCJKsc-Regular.otf"
		)
	dynamic_font.size = 18
	label.set("custom_fonts/normal_font", dynamic_font)

	add_child(label)
	set_process_input(true)
	set_process(true)
	active = true


func hide_box():
	background.queue_free()
	label.queue_free()
	active = false
	set_process_input(false)
	set_process(false)
	emit_signal("box_hidden")


func append_text(bbcode: String, duration: int):
	var current_tag: String = ""
	if not active:
		show_box()
		active = true
	for c in bbcode:
		# basically a FSM, there's no tag nesting
		if current_tag.length() > 0:
			if c != "]":
				current_tag += c
			else:
				elements.append(current_tag + "]")
				# tags are immediate
				element_times.append(0)
				current_tag = ""
		else:
			if  c != "[":
				elements.append(c)
				element_times.append(duration)
			else:
				current_tag = "["


# helper to react to the input event, preventing it from propagating
# and closing the dialogue box when done
func capture_input():
	if in_break:
		in_break = false
		get_tree().set_input_as_handled()
		set_process(true)
		emit_signal("break_ended", break_content)
		return
	else:
		skipped_time += skip_interval
	# if the buffer is not empty the dialogue is not over
	if elements.size() > 0:
		# let's wait for it without letting the input propagate
		get_tree().set_input_as_handled()
	else:
		if active:
			# the last input closes the box but still is not propagated
			get_tree().set_input_as_handled()
			hide_box()
