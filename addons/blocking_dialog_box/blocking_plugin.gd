tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("BlockingDialogBox","CanvasLayer", preload("blocking_dialog_box.gd"), preload("res://addons/blocking_dialog_box/dialog_node_icon.png"))
	add_custom_type("BlockingListSelection","CanvasLayer", preload("blocking_list_selection.gd"), preload("res://addons/blocking_dialog_box/dialog_node_icon.png"))
	add_custom_type("BlockingInputBox","CanvasLayer", preload("blocking_input_box.gd"), preload("res://addons/blocking_dialog_box/dialog_node_icon.png"))
	

func _exit_tree():
	# Clean-up of the plugin goes here
	remove_custom_type("BlockingDialogBox")
	remove_custom_type("BlockingListSelection")	
	remove_custom_type("BlockingInputBox")
