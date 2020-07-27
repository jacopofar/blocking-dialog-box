extends KinematicBody2D

var bdb: BlockingDialogBox 
var bls: BlockingListSelection

func _ready():
	bdb = get_node("/root/Main/BlockingDialogBox")
	bls = get_node("/root/Main/BlockingListSelection")
	
func on_interact():
	bdb.append_text("Hello\n", 20)
	bdb.append_text("What's your favorite number?\n[break ask_number]", 10)
	# warning-ignore:return_value_discarded
	bdb.connect("break_reached", self, "ask_number")


func ask_number(_unused: String):
	bdb.disconnect("break_reached", self, "ask_number")
	var numbers = ['infinite!']
	for i in range(30):
		numbers.append("The number " + str(i))
	bls.ask_value(numbers)
	# warning-ignore:return_value_discarded
	bls.connect("choice_made", self, "when_item_selected")

func when_item_selected(_index: int, text: String):
	bls.disconnect("choice_made", self, "when_item_selected")
	# this is to avoid the double input, one to close the selection and the other to continue the dialog
	# it's not striclty necessary, but nicer
	bdb.hide_box()
	bdb.append_text("Ah, so your favorite number is [color=red]" + text + "[/color]", 10)
	bdb.append_text("\nGood to know!", 10)
