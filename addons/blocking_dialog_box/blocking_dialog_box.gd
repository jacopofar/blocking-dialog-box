extends CanvasLayer
class_name BlockingDialogBox

export var patch_size: int = 12
export var padding: int = 6

export var height: int = 128

# elements to display, either single characters or BBCode tags
var elements: PoolStringArray = []
# time in ms to wait each element
var element_times: PoolIntArray = []
# time since the last element was added
var elapsed: int = 0

var label: RichTextLabel
var background: NinePatchRect

# is it visible and catching inputs?
var active: bool = false

func _ready():
	set_process(false)
#	set_process_input(false)

func show_box():
	background = NinePatchRect.new()
	background.rect_position = Vector2(padding, OS.window_size.y - height - padding)
	background.rect_size = Vector2(OS.window_size.x - 2 * padding, height)
	background.texture = load("res://addons/blocking_dialog_box/dialog_frame.png")
	background.patch_margin_top = patch_size
	background.patch_margin_right = patch_size
	background.patch_margin_bottom = patch_size
	background.patch_margin_left = patch_size
	add_child(background)
	
	label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.scroll_following = true
	label.rect_position = Vector2(padding * 2 + patch_size, OS.window_size.y - height + padding)
	label.rect_size = Vector2(OS.window_size.x - padding * 2, height - patch_size  - padding * 2)
	label.set("custom_colors/default_color", Color(0,0,0))
	add_child(label)
	
	
func _process(delta):
	elapsed += delta * 1000
	while true:
		if elapsed > element_times[0]:
			# carry the remaining time for the next element
			elapsed -= element_times[0]
			label.set_bbcode(label.get_bbcode() + elements[0])
			element_times.remove(0)
			elements.remove(0)
		else:
			break
		if elements.size() == 0:
			set_process(false)
			break

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
	set_process(true)

