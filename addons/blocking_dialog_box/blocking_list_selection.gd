extends CanvasLayer
class_name BlockingListSelection

signal choice_made(index, text)

# size of the NinePatch frame
export var patch_size: int = 12
# distance to let the text breathe
export var padding: int = 12

# distance from left and right borders
export var hmargin: int = 60

# item selection height
export var height: int = 300

# item selection bottom margin
export var bottom_margin: int = 64

var item_list: ItemList
var background: NinePatchRect

# is it visible and catching inputs?
var active: bool = false

# the possible choices for the user
var choices: PoolStringArray

# track the start of a multitouch event to later detect a swipe
var swipe_start: Vector2

func _ready():
	set_process(false)
	set_process_input(false)


func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_DOWN:
				scroll_relative(1)
			if event.scancode == KEY_UP:
				scroll_relative(-1)
			if event.scancode == KEY_PAGEUP:
				scroll_relative(-5)
			if event.scancode == KEY_PAGEDOWN:
				scroll_relative(5)
			if event.scancode == KEY_ENTER:
				choice(item_list.get_selected_items()[0])
			
		get_tree().set_input_as_handled()	
	if event is InputEventMouseButton:
		if event.pressed and not event.doubleclick:
			if event.button_index == BUTTON_WHEEL_UP:
				scroll_relative(1)
			if event.button_index == BUTTON_WHEEL_DOWN:
				scroll_relative(-1)
			if event.button_index == BUTTON_LEFT:
				var target = item_list.get_item_at_position(item_list.get_local_mouse_position(), true)
				if target != -1:
					item_list.select(target)
		if event.doubleclick:
			choice(item_list.get_selected_items()[0])
		get_tree().set_input_as_handled()
	if event is InputEventScreenTouch:
		# solution from https://godotengine.org/qa/19386/how-to-detect-swipe-using-3-0
		if event.pressed:
			swipe_start = item_list.get_local_mouse_position()
		else:
			_calculate_swipe(item_list.get_local_mouse_position())
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

	
	item_list = ItemList.new()
	for c in choices:
		item_list.add_item(c)
	# preselect the first, it doesn't trigger the signal
	item_list.select(0, true)
	
	item_list.rect_position = Vector2(
		hmargin + padding,
		window_size_y - height - bottom_margin + padding
		)
	item_list.rect_size = Vector2(
		window_size_x - 2 * (hmargin + padding),
		height - 2 * padding
		)
	var edit_style = StyleBoxFlat.new()
	edit_style.set_bg_color(Color.transparent)
	item_list.set("custom_styles/bg", edit_style)
	# text color of non-selected items
	item_list.set("custom_colors/font_color", Color(0.3, 0.3, 0.3))
	# text color of selected items
	item_list.set("custom_colors/font_color_selected", Color(0, 0, 0))
	# line between elements
	item_list.set("custom_colors/guide_color", Color(0.9, 0.9, 0.9))
	
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://addons/blocking_dialog_box/NotoSansCJKsc-Regular.otf")
	dynamic_font.size = 18
	item_list.set("custom_fonts/font", dynamic_font)
	
	add_child(background)
	add_child(item_list)
	set_process_input(true)
	set_process(true)
	active = true
	item_list.grab_focus()


func hide_box():
	background.queue_free()
	item_list.queue_free()
	active = false
	set_process_input(false)
	set_process(false)


func ask_value(elements: PoolStringArray):
	choices = elements
	if not active:
		show_box()
		active = true
		item_list.connect("item_activated", self, "choice")
	else:
		print("WARNING: asking for input while input box is already open!")

func choice(index: int):
	emit_signal("choice_made", index, choices[index])
	hide_box()


func scroll_relative(offset: int):
	var current_selected = item_list.get_selected_items()[0]
	var target = current_selected + offset
	target = min(target, len(choices) - 1)
	target = max(target, 0)
	item_list.select(target)
	item_list.ensure_current_is_visible()


func _calculate_swipe(swipe_end):
	if swipe_start == null:
		return
	var swipe = swipe_end - swipe_start
	print(swipe)
	if abs(swipe.y) > 30:
		if swipe.y > 0:
			scroll_relative(1)
		else:
			scroll_relative(-1)
	else:
		var target = item_list.get_item_at_position(swipe_end, true)
		# if you click on an item, you choose it
		# if you click outside you choose the currently selected one
		if target == -1:
			choice(item_list.get_selected_items()[0])
		else:
			choice(target)
