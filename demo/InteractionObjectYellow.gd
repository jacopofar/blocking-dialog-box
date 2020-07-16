extends KinematicBody2D

var bdb: BlockingDialogBox 
var bls: BlockingListSelection

func _ready():
	bdb = get_node("/root/Main/BlockingDialogBox")
	bls = get_node("/root/Main/BlockingListSelection")
	
func on_interact():
	bdb.append_text("Hello\n", 20)
	bdb.append_text("What's your favorite number?\n[break ask_number]", 10)
	bdb.connect("break_reached", self, "ask_number")	

func ask_number(_unused: String):
	var numbers = ['infinite!']
	for i in range(30):
		numbers.append("The number " + str(i))
	bls.ask_value(numbers)
	bls.connect("choice", self, "when_item_selected")

func when_item_selected(name: String):
	bdb.append_text("Ah, so your favorite number is [color=red]" + name + "[/color]", 10)
	bdb.append_text("\nGood to know!", 10)
